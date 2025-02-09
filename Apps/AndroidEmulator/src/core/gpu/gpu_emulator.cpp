#include <jni.h>
#include <android/log.h>
#include <EGL/egl.h>
#include <GLES3/gl3.h>
#include <string>
#include <vector>
#include <memory>
#include <thread>
#include <mutex>

#define LOG_TAG "GPUEmulator"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

class GPUEmulator {
private:
    std::mutex mtx;
    bool initialized = false;
    
    // EGL Context
    EGLDisplay display = EGL_NO_DISPLAY;
    EGLContext context = EGL_NO_CONTEXT;
    EGLSurface surface = EGL_NO_SURFACE;
    
    // OpenGL Resources
    GLuint frameBuffer = 0;
    GLuint renderBuffer = 0;
    GLuint shaderProgram = 0;
    
    // Emulator State
    struct GPUState {
        uint32_t width;
        uint32_t height;
        std::vector<uint8_t> frameBuffer;
    } state;
    
public:
    GPUEmulator() {
        LOGI("GPU Emulator created");
    }
    
    ~GPUEmulator() {
        cleanup();
    }
    
    bool initialize(uint32_t width, uint32_t height) {
        std::lock_guard<std::mutex> lock(mtx);
        
        if (initialized) {
            LOGI("GPU already initialized");
            return true;
        }
        
        // Initialize EGL
        display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
        if (display == EGL_NO_DISPLAY) {
            LOGE("Failed to get EGL display");
            return false;
        }
        
        EGLint majorVersion, minorVersion;
        if (!eglInitialize(display, &majorVersion, &minorVersion)) {
            LOGE("Failed to initialize EGL");
            return false;
        }
        
        // Configure EGL
        const EGLint configAttribs[] = {
            EGL_SURFACE_TYPE, EGL_PBUFFER_BIT,
            EGL_RENDERABLE_TYPE, EGL_OPENGL_ES3_BIT,
            EGL_RED_SIZE, 8,
            EGL_GREEN_SIZE, 8,
            EGL_BLUE_SIZE, 8,
            EGL_ALPHA_SIZE, 8,
            EGL_DEPTH_SIZE, 24,
            EGL_STENCIL_SIZE, 8,
            EGL_NONE
        };
        
        EGLConfig config;
        EGLint numConfigs;
        if (!eglChooseConfig(display, configAttribs, &config, 1, &numConfigs)) {
            LOGE("Failed to choose EGL config");
            return false;
        }
        
        // Create EGL Context
        const EGLint contextAttribs[] = {
            EGL_CONTEXT_CLIENT_VERSION, 3,
            EGL_NONE
        };
        
        context = eglCreateContext(display, config, EGL_NO_CONTEXT, contextAttribs);
        if (context == EGL_NO_CONTEXT) {
            LOGE("Failed to create EGL context");
            return false;
        }
        
        // Create Pbuffer Surface
        const EGLint surfaceAttribs[] = {
            EGL_WIDTH, static_cast<EGLint>(width),
            EGL_HEIGHT, static_cast<EGLint>(height),
            EGL_NONE
        };
        
        surface = eglCreatePbufferSurface(display, config, surfaceAttribs);
        if (surface == EGL_NO_SURFACE) {
            LOGE("Failed to create EGL surface");
            return false;
        }
        
        if (!eglMakeCurrent(display, surface, surface, context)) {
            LOGE("Failed to make EGL context current");
            return false;
        }
        
        // Initialize OpenGL Resources
        glGenFramebuffers(1, &frameBuffer);
        glGenRenderbuffers(1, &renderBuffer);
        
        glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
        
        glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8, width, height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            LOGE("Framebuffer is not complete");
            return false;
        }
        
        // Initialize Shader Program
        if (!initShaders()) {
            LOGE("Failed to initialize shaders");
            return false;
        }
        
        // Initialize State
        state.width = width;
        state.height = height;
        state.frameBuffer.resize(width * height * 4);
        
        initialized = true;
        LOGI("GPU initialized successfully");
        return true;
    }
    
    void cleanup() {
        std::lock_guard<std::mutex> lock(mtx);
        
        if (!initialized) {
            return;
        }
        
        if (shaderProgram) {
            glDeleteProgram(shaderProgram);
            shaderProgram = 0;
        }
        
        if (frameBuffer) {
            glDeleteFramebuffers(1, &frameBuffer);
            frameBuffer = 0;
        }
        
        if (renderBuffer) {
            glDeleteRenderbuffers(1, &renderBuffer);
            renderBuffer = 0;
        }
        
        if (display != EGL_NO_DISPLAY) {
            eglMakeCurrent(display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
            
            if (context != EGL_NO_CONTEXT) {
                eglDestroyContext(display, context);
                context = EGL_NO_CONTEXT;
            }
            
            if (surface != EGL_NO_SURFACE) {
                eglDestroySurface(display, surface);
                surface = EGL_NO_SURFACE;
            }
            
            eglTerminate(display);
            display = EGL_NO_DISPLAY;
        }
        
        initialized = false;
        LOGI("GPU cleanup complete");
    }
    
    bool render(const void* vertices, size_t vertexCount) {
        if (!initialized) {
            LOGE("GPU not initialized");
            return false;
        }
        
        std::lock_guard<std::mutex> lock(mtx);
        
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        glUseProgram(shaderProgram);
        
        // Set up vertex data
        GLuint vbo;
        glGenBuffers(1, &vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, vertexCount * sizeof(float) * 3, vertices, GL_STATIC_DRAW);
        
        // Set up vertex attributes
        GLint posAttrib = glGetAttribLocation(shaderProgram, "position");
        glEnableVertexAttribArray(posAttrib);
        glVertexAttribPointer(posAttrib, 3, GL_FLOAT, GL_FALSE, 0, 0);
        
        // Draw
        glDrawArrays(GL_TRIANGLES, 0, vertexCount);
        
        // Cleanup
        glDeleteBuffers(1, &vbo);
        
        // Read pixels
        glReadPixels(0, 0, state.width, state.height, GL_RGBA, GL_UNSIGNED_BYTE, state.frameBuffer.data());
        
        return true;
    }
    
    const uint8_t* getFrameBuffer() const {
        return state.frameBuffer.data();
    }
    
private:
    bool initShaders() {
        const char* vertexShaderSource = R"(
            #version 300 es
            in vec3 position;
            void main() {
                gl_Position = vec4(position, 1.0);
            }
        )";
        
        const char* fragmentShaderSource = R"(
            #version 300 es
            precision mediump float;
            out vec4 fragColor;
            void main() {
                fragColor = vec4(1.0, 0.0, 0.0, 1.0);
            }
        )";
        
        // Compile vertex shader
        GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(vertexShader, 1, &vertexShaderSource, nullptr);
        glCompileShader(vertexShader);
        
        GLint success;
        glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
        if (!success) {
            GLchar infoLog[512];
            glGetShaderInfoLog(vertexShader, sizeof(infoLog), nullptr, infoLog);
            LOGE("Vertex shader compilation failed: %s", infoLog);
            return false;
        }
        
        // Compile fragment shader
        GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(fragmentShader, 1, &fragmentShaderSource, nullptr);
        glCompileShader(fragmentShader);
        
        glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
        if (!success) {
            GLchar infoLog[512];
            glGetShaderInfoLog(fragmentShader, sizeof(infoLog), nullptr, infoLog);
            LOGE("Fragment shader compilation failed: %s", infoLog);
            return false;
        }
        
        // Link shaders
        shaderProgram = glCreateProgram();
        glAttachShader(shaderProgram, vertexShader);
        glAttachShader(shaderProgram, fragmentShader);
        glLinkProgram(shaderProgram);
        
        glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
        if (!success) {
            GLchar infoLog[512];
            glGetProgramInfoLog(shaderProgram, sizeof(infoLog), nullptr, infoLog);
            LOGE("Shader program linking failed: %s", infoLog);
            return false;
        }
        
        glDeleteShader(vertexShader);
        glDeleteShader(fragmentShader);
        
        return true;
    }
};

// JNI Interface
extern "C" {
    static GPUEmulator* emulator = nullptr;
    
    JNIEXPORT jint JNICALL
    Java_com_android_emulator_GPUEmulator_init(JNIEnv* env, jobject obj, jint width, jint height) {
        if (emulator != nullptr) {
            delete emulator;
        }
        
        try {
            emulator = new GPUEmulator();
            return emulator->initialize(width, height) ? 0 : -1;
        } catch (const std::exception& e) {
            LOGE("Failed to initialize GPU emulator: %s", e.what());
            return -1;
        }
    }
    
    JNIEXPORT void JNICALL
    Java_com_android_emulator_GPUEmulator_cleanup(JNIEnv* env, jobject obj) {
        if (emulator != nullptr) {
            delete emulator;
            emulator = nullptr;
        }
    }
    
    JNIEXPORT jboolean JNICALL
    Java_com_android_emulator_GPUEmulator_render(JNIEnv* env, jobject obj, jfloatArray vertices, jint vertexCount) {
        if (emulator == nullptr) {
            return JNI_FALSE;
        }
        
        jfloat* buffer = env->GetFloatArrayElements(vertices, nullptr);
        bool result = emulator->render(buffer, vertexCount);
        env->ReleaseFloatArrayElements(vertices, buffer, JNI_ABORT);
        
        return result ? JNI_TRUE : JNI_FALSE;
    }
    
    JNIEXPORT jbyteArray JNICALL
    Java_com_android_emulator_GPUEmulator_getFrameBuffer(JNIEnv* env, jobject obj) {
        if (emulator == nullptr) {
            return nullptr;
        }
        
        const uint8_t* buffer = emulator->getFrameBuffer();
        if (buffer == nullptr) {
            return nullptr;
        }
        
        jbyteArray result = env->NewByteArray(1920 * 1080 * 4); // Assuming 1080p
        env->SetByteArrayRegion(result, 0, 1920 * 1080 * 4, reinterpret_cast<const jbyte*>(buffer));
        
        return result;
    }
}
