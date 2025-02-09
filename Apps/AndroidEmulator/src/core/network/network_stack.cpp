#include <jni.h>
#include <android/log.h>
#include <string>
#include <vector>
#include <memory>
#include <thread>
#include <mutex>
#include <queue>
#include <map>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

#define LOG_TAG "NetworkStack"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

class NetworkStack {
private:
    std::mutex mtx;
    bool initialized = false;
    
    // Network Configuration
    static const int MAX_CONNECTIONS = 1024;
    static const int BUFFER_SIZE = 8192;
    
    // Network State
    struct Connection {
        int socket;
        std::string address;
        uint16_t port;
        std::vector<uint8_t> receiveBuffer;
        std::queue<std::vector<uint8_t>> sendQueue;
    };
    
    struct NetworkState {
        std::map<int, std::unique_ptr<Connection>> connections;
        std::thread networkThread;
        bool running;
        int listenSocket;
    } state;
    
public:
    NetworkStack() {
        LOGI("Network Stack created");
    }
    
    ~NetworkStack() {
        cleanup();
    }
    
    bool initialize(uint16_t port) {
        std::lock_guard<std::mutex> lock(mtx);
        
        if (initialized) {
            LOGI("Network already initialized");
            return true;
        }
        
        // Create listen socket
        state.listenSocket = socket(AF_INET, SOCK_STREAM, 0);
        if (state.listenSocket < 0) {
            LOGE("Failed to create listen socket: %s", strerror(errno));
            return false;
        }
        
        // Set socket options
        int opt = 1;
        if (setsockopt(state.listenSocket, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &opt, sizeof(opt))) {
            LOGE("Failed to set socket options: %s", strerror(errno));
            close(state.listenSocket);
            return false;
        }
        
        // Set non-blocking
        int flags = fcntl(state.listenSocket, F_GETFL, 0);
        if (flags < 0) {
            LOGE("Failed to get socket flags: %s", strerror(errno));
            close(state.listenSocket);
            return false;
        }
        
        if (fcntl(state.listenSocket, F_SETFL, flags | O_NONBLOCK) < 0) {
            LOGE("Failed to set non-blocking: %s", strerror(errno));
            close(state.listenSocket);
            return false;
        }
        
        // Bind socket
        struct sockaddr_in address;
        address.sin_family = AF_INET;
        address.sin_addr.s_addr = INADDR_ANY;
        address.sin_port = htons(port);
        
        if (bind(state.listenSocket, (struct sockaddr*)&address, sizeof(address)) < 0) {
            LOGE("Failed to bind socket: %s", strerror(errno));
            close(state.listenSocket);
            return false;
        }
        
        // Listen
        if (listen(state.listenSocket, MAX_CONNECTIONS) < 0) {
            LOGE("Failed to listen: %s", strerror(errno));
            close(state.listenSocket);
            return false;
        }
        
        // Start network thread
        state.running = true;
        state.networkThread = std::thread(&NetworkStack::networkLoop, this);
        
        initialized = true;
        LOGI("Network initialized successfully on port %d", port);
        return true;
    }
    
    void cleanup() {
        std::lock_guard<std::mutex> lock(mtx);
        
        if (!initialized) {
            return;
        }
        
        // Stop network thread
        state.running = false;
        if (state.networkThread.joinable()) {
            state.networkThread.join();
        }
        
        // Close all connections
        for (auto& pair : state.connections) {
            close(pair.second->socket);
        }
        state.connections.clear();
        
        // Close listen socket
        if (state.listenSocket >= 0) {
            close(state.listenSocket);
            state.listenSocket = -1;
        }
        
        initialized = false;
        LOGI("Network cleanup complete");
    }
    
    bool send(int connectionId, const void* data, size_t size) {
        if (!initialized) {
            LOGE("Network not initialized");
            return false;
        }
        
        std::lock_guard<std::mutex> lock(mtx);
        
        auto it = state.connections.find(connectionId);
        if (it == state.connections.end()) {
            LOGE("Connection %d not found", connectionId);
            return false;
        }
        
        std::vector<uint8_t> buffer(static_cast<const uint8_t*>(data),
                                  static_cast<const uint8_t*>(data) + size);
        it->second->sendQueue.push(std::move(buffer));
        
        return true;
    }
    
private:
    void networkLoop() {
        LOGI("Network thread started");
        
        while (state.running) {
            std::lock_guard<std::mutex> lock(mtx);
            
            // Accept new connections
            struct sockaddr_in clientAddr;
            socklen_t clientLen = sizeof(clientAddr);
            
            int clientSocket = accept(state.listenSocket, (struct sockaddr*)&clientAddr, &clientLen);
            if (clientSocket >= 0) {
                // Set non-blocking
                int flags = fcntl(clientSocket, F_GETFL, 0);
                if (flags >= 0) {
                    if (fcntl(clientSocket, F_SETFL, flags | O_NONBLOCK) >= 0) {
                        auto conn = std::make_unique<Connection>();
                        conn->socket = clientSocket;
                        conn->address = inet_ntoa(clientAddr.sin_addr);
                        conn->port = ntohs(clientAddr.sin_port);
                        conn->receiveBuffer.resize(BUFFER_SIZE);
                        
                        state.connections[clientSocket] = std::move(conn);
                        LOGI("New connection from %s:%d", conn->address.c_str(), conn->port);
                    } else {
                        LOGE("Failed to set client non-blocking: %s", strerror(errno));
                        close(clientSocket);
                    }
                } else {
                    LOGE("Failed to get client flags: %s", strerror(errno));
                    close(clientSocket);
                }
            }
            
            // Handle existing connections
            for (auto it = state.connections.begin(); it != state.connections.end();) {
                auto& conn = it->second;
                
                // Handle receives
                ssize_t received = recv(conn->socket, conn->receiveBuffer.data(),
                                      conn->receiveBuffer.size(), MSG_DONTWAIT);
                
                if (received > 0) {
                    // Process received data
                    processReceivedData(conn.get(), received);
                } else if (received == 0 || (received < 0 && errno != EAGAIN && errno != EWOULDBLOCK)) {
                    // Connection closed or error
                    LOGI("Connection closed from %s:%d", conn->address.c_str(), conn->port);
                    close(conn->socket);
                    it = state.connections.erase(it);
                    continue;
                }
                
                // Handle sends
                while (!conn->sendQueue.empty()) {
                    const auto& buffer = conn->sendQueue.front();
                    ssize_t sent = send(conn->socket, buffer.data(), buffer.size(), MSG_DONTWAIT);
                    
                    if (sent > 0) {
                        conn->sendQueue.pop();
                    } else if (sent < 0 && errno != EAGAIN && errno != EWOULDBLOCK) {
                        // Send error
                        LOGE("Send error for %s:%d: %s", conn->address.c_str(), conn->port,
                             strerror(errno));
                        close(conn->socket);
                        it = state.connections.erase(it);
                        goto next_connection;
                    } else {
                        // Would block, try again later
                        break;
                    }
                }
                
                ++it;
                next_connection:;
            }
            
            // Sleep a bit to prevent busy waiting
            std::this_thread::sleep_for(std::chrono::milliseconds(1));
        }
        
        LOGI("Network thread stopped");
    }
    
    void processReceivedData(Connection* conn, size_t size) {
        // Process the received data according to your protocol
        // This is just a simple echo example
        send(conn->socket, conn->receiveBuffer.data(), size);
    }
};

// JNI Interface
extern "C" {
    static NetworkStack* stack = nullptr;
    
    JNIEXPORT jint JNICALL
    Java_com_android_emulator_NetworkStack_init(JNIEnv* env, jobject obj, jint port) {
        if (stack != nullptr) {
            delete stack;
        }
        
        try {
            stack = new NetworkStack();
            return stack->initialize(static_cast<uint16_t>(port)) ? 0 : -1;
        } catch (const std::exception& e) {
            LOGE("Failed to initialize network stack: %s", e.what());
            return -1;
        }
    }
    
    JNIEXPORT void JNICALL
    Java_com_android_emulator_NetworkStack_cleanup(JNIEnv* env, jobject obj) {
        if (stack != nullptr) {
            delete stack;
            stack = nullptr;
        }
    }
    
    JNIEXPORT jboolean JNICALL
    Java_com_android_emulator_NetworkStack_send(JNIEnv* env, jobject obj, jint connectionId,
                                              jbyteArray data) {
        if (stack == nullptr) {
            return JNI_FALSE;
        }
        
        jsize size = env->GetArrayLength(data);
        jbyte* buffer = env->GetByteArrayElements(data, nullptr);
        
        bool result = stack->send(connectionId, buffer, size);
        
        env->ReleaseByteArrayElements(data, buffer, JNI_ABORT);
        return result ? JNI_TRUE : JNI_FALSE;
    }
}
