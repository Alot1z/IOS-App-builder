#include <jni.h>
#include <android/log.h>
#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_Android.h>
#include <string>
#include <vector>
#include <memory>
#include <thread>
#include <mutex>
#include <queue>

#define LOG_TAG "AudioEmulator"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

class AudioEmulator {
private:
    std::mutex mtx;
    bool initialized = false;
    
    // OpenSL ES Objects
    SLObjectItf engineObject = nullptr;
    SLEngineItf engineEngine = nullptr;
    SLObjectItf outputMixObject = nullptr;
    SLObjectItf playerObject = nullptr;
    SLPlayItf playerPlay = nullptr;
    SLAndroidSimpleBufferQueueItf playerBufferQueue = nullptr;
    
    // Audio Configuration
    static const size_t BUFFER_SIZE = 4096;
    static const size_t SAMPLE_RATE = 44100;
    static const size_t CHANNELS = 2;
    
    // Audio State
    struct AudioState {
        std::queue<std::vector<int16_t>> bufferQueue;
        std::vector<int16_t> currentBuffer;
        bool playing;
    } state;
    
public:
    AudioEmulator() {
        LOGI("Audio Emulator created");
    }
    
    ~AudioEmulator() {
        cleanup();
    }
    
    bool initialize() {
        std::lock_guard<std::mutex> lock(mtx);
        
        if (initialized) {
            LOGI("Audio already initialized");
            return true;
        }
        
        // Create engine
        SLresult result = slCreateEngine(&engineObject, 0, nullptr, 0, nullptr, nullptr);
        if (result != SL_RESULT_SUCCESS) {
            LOGE("Failed to create engine: %d", result);
            return false;
        }
        
        // Realize the engine
        result = (*engineObject)->Realize(engineObject, SL_BOOLEAN_FALSE);
        if (result != SL_RESULT_SUCCESS) {
            LOGE("Failed to realize engine: %d", result);
            return false;
        }
        
        // Get the engine interface
        result = (*engineObject)->GetInterface(engineObject, SL_IID_ENGINE, &engineEngine);
        if (result != SL_RESULT_SUCCESS) {
            LOGE("Failed to get engine interface: %d", result);
            return false;
        }
        
        // Create output mix
        result = (*engineEngine)->CreateOutputMix(engineEngine, &outputMixObject, 0, nullptr, nullptr);
        if (result != SL_RESULT_SUCCESS) {
            LOGE("Failed to create output mix: %d", result);
            return false;
        }
        
        // Realize the output mix
        result = (*outputMixObject)->Realize(outputMixObject, SL_BOOLEAN_FALSE);
        if (result != SL_RESULT_SUCCESS) {
            LOGE("Failed to realize output mix: %d", result);
            return false;
        }
        
        // Configure audio source
        SLDataLocator_AndroidSimpleBufferQueue loc_bufq = {
            SL_DATALOCATOR_ANDROIDSIMPLEBUFFERQUEUE,
            2
        };
        
        SLDataFormat_PCM format_pcm = {
            SL_DATAFORMAT_PCM,
            CHANNELS,
            SL_SAMPLINGRATE_44_1,
            SL_PCMSAMPLEFORMAT_FIXED_16,
            SL_PCMSAMPLEFORMAT_FIXED_16,
            SL_SPEAKER_FRONT_LEFT | SL_SPEAKER_FRONT_RIGHT,
            SL_BYTEORDER_LITTLEENDIAN
        };
        
        SLDataSource audioSrc = {&loc_bufq, &format_pcm};
        
        // Configure audio sink
        SLDataLocator_OutputMix loc_outmix = {
            SL_DATALOCATOR_OUTPUTMIX,
            outputMixObject
        };
        SLDataSink audioSnk = {&loc_outmix, nullptr};
        
        // Create audio player
        const SLInterfaceID ids[2] = {SL_IID_BUFFERQUEUE, SL_IID_VOLUME};
        const SLboolean req[2] = {SL_BOOLEAN_TRUE, SL_BOOLEAN_TRUE};
        
        result = (*engineEngine)->CreateAudioPlayer(engineEngine, &playerObject, &audioSrc, &audioSnk, 2, ids, req);
        if (result != SL_RESULT_SUCCESS) {
            LOGE("Failed to create audio player: %d", result);
            return false;
        }
        
        // Realize the player
        result = (*playerObject)->Realize(playerObject, SL_BOOLEAN_FALSE);
        if (result != SL_RESULT_SUCCESS) {
            LOGE("Failed to realize player: %d", result);
            return false;
        }
        
        // Get the play interface
        result = (*playerObject)->GetInterface(playerObject, SL_IID_PLAY, &playerPlay);
        if (result != SL_RESULT_SUCCESS) {
            LOGE("Failed to get play interface: %d", result);
            return false;
        }
        
        // Get the buffer queue interface
        result = (*playerObject)->GetInterface(playerObject, SL_IID_BUFFERQUEUE, &playerBufferQueue);
        if (result != SL_RESULT_SUCCESS) {
            LOGE("Failed to get buffer queue interface: %d", result);
            return false;
        }
        
        // Register callback
        result = (*playerBufferQueue)->RegisterCallback(playerBufferQueue, bufferQueueCallback, this);
        if (result != SL_RESULT_SUCCESS) {
            LOGE("Failed to register callback: %d", result);
            return false;
        }
        
        // Initialize state
        state.playing = false;
        state.currentBuffer.resize(BUFFER_SIZE);
        
        initialized = true;
        LOGI("Audio initialized successfully");
        return true;
    }
    
    void cleanup() {
        std::lock_guard<std::mutex> lock(mtx);
        
        if (!initialized) {
            return;
        }
        
        if (playerObject != nullptr) {
            (*playerObject)->Destroy(playerObject);
            playerObject = nullptr;
            playerPlay = nullptr;
            playerBufferQueue = nullptr;
        }
        
        if (outputMixObject != nullptr) {
            (*outputMixObject)->Destroy(outputMixObject);
            outputMixObject = nullptr;
        }
        
        if (engineObject != nullptr) {
            (*engineObject)->Destroy(engineObject);
            engineObject = nullptr;
            engineEngine = nullptr;
        }
        
        initialized = false;
        LOGI("Audio cleanup complete");
    }
    
    bool play() {
        if (!initialized) {
            LOGE("Audio not initialized");
            return false;
        }
        
        std::lock_guard<std::mutex> lock(mtx);
        
        if (state.playing) {
            LOGI("Audio already playing");
            return true;
        }
        
        // Set the player's state to playing
        SLresult result = (*playerPlay)->SetPlayState(playerPlay, SL_PLAYSTATE_PLAYING);
        if (result != SL_RESULT_SUCCESS) {
            LOGE("Failed to start playback: %d", result);
            return false;
        }
        
        state.playing = true;
        
        // Enqueue initial buffer
        result = (*playerBufferQueue)->Enqueue(playerBufferQueue, state.currentBuffer.data(),
                                             state.currentBuffer.size() * sizeof(int16_t));
        if (result != SL_RESULT_SUCCESS) {
            LOGE("Failed to enqueue buffer: %d", result);
            return false;
        }
        
        return true;
    }
    
    bool stop() {
        if (!initialized) {
            LOGE("Audio not initialized");
            return false;
        }
        
        std::lock_guard<std::mutex> lock(mtx);
        
        if (!state.playing) {
            LOGI("Audio already stopped");
            return true;
        }
        
        // Set the player's state to stopped
        SLresult result = (*playerPlay)->SetPlayState(playerPlay, SL_PLAYSTATE_STOPPED);
        if (result != SL_RESULT_SUCCESS) {
            LOGE("Failed to stop playback: %d", result);
            return false;
        }
        
        state.playing = false;
        
        // Clear buffer queue
        result = (*playerBufferQueue)->Clear(playerBufferQueue);
        if (result != SL_RESULT_SUCCESS) {
            LOGE("Failed to clear buffer queue: %d", result);
            return false;
        }
        
        while (!state.bufferQueue.empty()) {
            state.bufferQueue.pop();
        }
        
        return true;
    }
    
    bool queueAudio(const int16_t* data, size_t size) {
        if (!initialized) {
            LOGE("Audio not initialized");
            return false;
        }
        
        std::lock_guard<std::mutex> lock(mtx);
        
        std::vector<int16_t> buffer(data, data + size);
        state.bufferQueue.push(std::move(buffer));
        
        return true;
    }
    
private:
    static void bufferQueueCallback(SLAndroidSimpleBufferQueueItf bq, void* context) {
        auto* emulator = static_cast<AudioEmulator*>(context);
        emulator->handleBufferQueue();
    }
    
    void handleBufferQueue() {
        std::lock_guard<std::mutex> lock(mtx);
        
        if (!state.bufferQueue.empty()) {
            // Get next buffer
            state.currentBuffer = std::move(state.bufferQueue.front());
            state.bufferQueue.pop();
            
            // Enqueue the buffer
            SLresult result = (*playerBufferQueue)->Enqueue(playerBufferQueue,
                                                          state.currentBuffer.data(),
                                                          state.currentBuffer.size() * sizeof(int16_t));
            if (result != SL_RESULT_SUCCESS) {
                LOGE("Failed to enqueue buffer in callback: %d", result);
            }
        }
    }
};

// JNI Interface
extern "C" {
    static AudioEmulator* emulator = nullptr;
    
    JNIEXPORT jint JNICALL
    Java_com_android_emulator_AudioEmulator_init(JNIEnv* env, jobject obj) {
        if (emulator != nullptr) {
            delete emulator;
        }
        
        try {
            emulator = new AudioEmulator();
            return emulator->initialize() ? 0 : -1;
        } catch (const std::exception& e) {
            LOGE("Failed to initialize audio emulator: %s", e.what());
            return -1;
        }
    }
    
    JNIEXPORT void JNICALL
    Java_com_android_emulator_AudioEmulator_cleanup(JNIEnv* env, jobject obj) {
        if (emulator != nullptr) {
            delete emulator;
            emulator = nullptr;
        }
    }
    
    JNIEXPORT jboolean JNICALL
    Java_com_android_emulator_AudioEmulator_play(JNIEnv* env, jobject obj) {
        return (emulator != nullptr && emulator->play()) ? JNI_TRUE : JNI_FALSE;
    }
    
    JNIEXPORT jboolean JNICALL
    Java_com_android_emulator_AudioEmulator_stop(JNIEnv* env, jobject obj) {
        return (emulator != nullptr && emulator->stop()) ? JNI_TRUE : JNI_FALSE;
    }
    
    JNIEXPORT jboolean JNICALL
    Java_com_android_emulator_AudioEmulator_queueAudio(JNIEnv* env, jobject obj, jshortArray data) {
        if (emulator == nullptr) {
            return JNI_FALSE;
        }
        
        jsize size = env->GetArrayLength(data);
        jshort* buffer = env->GetShortArrayElements(data, nullptr);
        
        bool result = emulator->queueAudio(reinterpret_cast<int16_t*>(buffer), size);
        
        env->ReleaseShortArrayElements(data, buffer, JNI_ABORT);
        return result ? JNI_TRUE : JNI_FALSE;
    }
}
