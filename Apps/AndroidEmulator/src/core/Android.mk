LOCAL_PATH := $(call my-dir)

# CPU Emulator
include $(CLEAR_VARS)
LOCAL_MODULE := emulator-cpu
LOCAL_SRC_FILES := cpu/cpu_emulator.cpp
LOCAL_CFLAGS := -O3 -march=armv8-a
LOCAL_LDLIBS := -llog -landroid
include $(BUILD_SHARED_LIBRARY)

# GPU Emulator
include $(CLEAR_VARS)
LOCAL_MODULE := emulator-gpu
LOCAL_SRC_FILES := gpu/gpu_emulator.cpp
LOCAL_CFLAGS := -O3 -march=armv8-a
LOCAL_LDLIBS := -llog -landroid -lEGL -lGLESv3
include $(BUILD_SHARED_LIBRARY)

# Audio Emulator
include $(CLEAR_VARS)
LOCAL_MODULE := emulator-audio
LOCAL_SRC_FILES := audio/audio_emulator.cpp
LOCAL_CFLAGS := -O3 -march=armv8-a
LOCAL_LDLIBS := -llog -landroid -lOpenSLES
include $(BUILD_SHARED_LIBRARY)

# Network Stack
include $(CLEAR_VARS)
LOCAL_MODULE := emulator-network
LOCAL_SRC_FILES := network/network_stack.cpp
LOCAL_CFLAGS := -O3 -march=armv8-a
LOCAL_LDLIBS := -llog -landroid
include $(BUILD_SHARED_LIBRARY)
