#include <android/native_window.h>
#include <android/input.h>
#include <EGL/egl.h>
#include <GLES3/gl3.h>
#include <memory>
#include <vector>
#include <queue>
#include <mutex>

class WindowManager {
private:
    // EGL context
    EGLDisplay display;
    EGLContext context;
    EGLSurface surface;
    
    // Window state
    ANativeWindow* window;
    int32_t width;
    int32_t height;
    bool isRotated;
    
    // Input handling
    std::mutex inputMutex;
    std::queue<AInputEvent*> inputQueue;
    
    // Gesture recognition
    struct GestureState {
        bool isTracking;
        float startX;
        float startY;
        float lastX;
        float lastY;
        int64_t startTime;
    } gestureState;
    
public:
    bool initialize(ANativeWindow* nativeWindow) {
        window = nativeWindow;
        width = ANativeWindow_getWidth(window);
        height = ANativeWindow_getHeight(window);
        isRotated = false;
        
        // Initialize EGL
        display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
        if (display == EGL_NO_DISPLAY) {
            return false;
        }
        
        EGLint major, minor;
        if (!eglInitialize(display, &major, &minor)) {
            return false;
        }
        
        // Configure EGL
        const EGLint configAttribs[] = {
            EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
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
            return false;
        }
        
        // Create context
        const EGLint contextAttribs[] = {
            EGL_CONTEXT_CLIENT_VERSION, 3,
            EGL_NONE
        };
        
        context = eglCreateContext(display, config, EGL_NO_CONTEXT, contextAttribs);
        if (context == EGL_NO_CONTEXT) {
            return false;
        }
        
        // Create surface
        surface = eglCreateWindowSurface(display, config, window, nullptr);
        if (surface == EGL_NO_SURFACE) {
            return false;
        }
        
        if (!eglMakeCurrent(display, surface, surface, context)) {
            return false;
        }
        
        // Initialize OpenGL ES
        glViewport(0, 0, width, height);
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        
        return true;
    }
    
    void handleInput(AInputEvent* event) {
        std::lock_guard<std::mutex> lock(inputMutex);
        
        if (AInputEvent_getType(event) == AINPUT_EVENT_TYPE_MOTION) {
            float x = AMotionEvent_getX(event, 0);
            float y = AMotionEvent_getY(event, 0);
            
            switch (AMotionEvent_getAction(event) & AMOTION_EVENT_ACTION_MASK) {
                case AMOTION_EVENT_ACTION_DOWN:
                    startGesture(x, y);
                    break;
                    
                case AMOTION_EVENT_ACTION_MOVE:
                    updateGesture(x, y);
                    break;
                    
                case AMOTION_EVENT_ACTION_UP:
                    endGesture(x, y);
                    break;
            }
        }
        
        inputQueue.push(event);
    }
    
    void startGesture(float x, float y) {
        gestureState.isTracking = true;
        gestureState.startX = x;
        gestureState.startY = y;
        gestureState.lastX = x;
        gestureState.lastY = y;
        gestureState.startTime = AMotionEvent_getEventTime(nullptr);
    }
    
    void updateGesture(float x, float y) {
        if (!gestureState.isTracking) {
            return;
        }
        
        float deltaX = x - gestureState.lastX;
        float deltaY = y - gestureState.lastY;
        
        // Check for rotation gesture
        if (std::abs(deltaX) > 100.0f || std::abs(deltaY) > 100.0f) {
            handleRotation(deltaX, deltaY);
        }
        
        gestureState.lastX = x;
        gestureState.lastY = y;
    }
    
    void endGesture(float x, float y) {
        if (!gestureState.isTracking) {
            return;
        }
        
        // Check for tap
        float deltaX = x - gestureState.startX;
        float deltaY = y - gestureState.startY;
        int64_t deltaTime = AMotionEvent_getEventTime(nullptr) - gestureState.startTime;
        
        if (std::abs(deltaX) < 10.0f && std::abs(deltaY) < 10.0f && deltaTime < 200000000) {
            handleTap(x, y);
        }
        
        gestureState.isTracking = false;
    }
    
    void handleRotation(float deltaX, float deltaY) {
        if (std::abs(deltaX) > std::abs(deltaY)) {
            // Horizontal rotation
            isRotated = !isRotated;
            int32_t newWidth = height;
            int32_t newHeight = width;
            
            ANativeWindow_setBuffersGeometry(window, newWidth, newHeight, 
                                           ANativeWindow_getFormat(window));
            
            width = newWidth;
            height = newHeight;
            glViewport(0, 0, width, height);
        }
    }
    
    void handleTap(float x, float y) {
        // Convert coordinates to Android coordinate space
        float androidX = x / width;
        float androidY = y / height;
        
        if (isRotated) {
            std::swap(androidX, androidY);
            androidY = 1.0f - androidY;
        }
        
        // Send tap event to Android system
        AInputEvent* tapEvent;
        // TODO: Create and queue tap event
    }
    
    void render() {
        if (!eglMakeCurrent(display, surface, surface, context)) {
            return;
        }
        
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        // TODO: Render Android UI
        
        eglSwapBuffers(display, surface);
    }
    
    void cleanup() {
        if (display != EGL_NO_DISPLAY) {
            eglMakeCurrent(display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
            
            if (surface != EGL_NO_SURFACE) {
                eglDestroySurface(display, surface);
            }
            
            if (context != EGL_NO_CONTEXT) {
                eglDestroyContext(display, context);
            }
            
            eglTerminate(display);
        }
        
        // Clear input queue
        std::lock_guard<std::mutex> lock(inputMutex);
        while (!inputQueue.empty()) {
            AInputEvent_release(inputQueue.front());
            inputQueue.pop();
        }
    }
};

// JNI Interface
extern "C" {
    static WindowManager* windowManager = nullptr;
    
    JNIEXPORT jint JNICALL
    Java_com_android_emulator_WindowManager_init(JNIEnv* env, jobject obj,
                                               jobject surface) {
        if (windowManager != nullptr) {
            delete windowManager;
        }
        
        try {
            ANativeWindow* window = ANativeWindow_fromSurface(env, surface);
            if (!window) {
                return -1;
            }
            
            windowManager = new WindowManager();
            return windowManager->initialize(window) ? 0 : -1;
        } catch (const std::exception& e) {
            return -1;
        }
    }
    
    JNIEXPORT void JNICALL
    Java_com_android_emulator_WindowManager_cleanup(JNIEnv* env, jobject obj) {
        if (windowManager != nullptr) {
            windowManager->cleanup();
            delete windowManager;
            windowManager = nullptr;
        }
    }
    
    JNIEXPORT void JNICALL
    Java_com_android_emulator_WindowManager_render(JNIEnv* env, jobject obj) {
        if (windowManager != nullptr) {
            windowManager->render();
        }
    }
    
    JNIEXPORT void JNICALL
    Java_com_android_emulator_WindowManager_handleInput(JNIEnv* env, jobject obj,
                                                      jobject event) {
        if (windowManager != nullptr) {
            AInputEvent* nativeEvent = AInputEvent_fromJava(event);
            if (nativeEvent) {
                windowManager->handleInput(nativeEvent);
            }
        }
    }
}
