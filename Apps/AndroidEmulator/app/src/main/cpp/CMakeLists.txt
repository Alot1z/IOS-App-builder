cmake_minimum_required(VERSION 3.22.1)

project("androidemulator")

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add source files
add_library(emulator-core SHARED
    core/audio/audio_emulator.cpp
    core/cpu/cpu_emulator.cpp
    core/gpu/gpu_emulator.cpp
    core/network/network_stack.cpp
    core/runtime/android_runtime.cpp
    core/ui/window_manager.cpp
)

# Find required packages
find_library(log-lib log)
find_library(android-lib android)
find_library(EGL-lib EGL)
find_library(GLESv3-lib GLESv3)

# Link libraries
target_link_libraries(emulator-core
    ${log-lib}
    ${android-lib}
    ${EGL-lib}
    ${GLESv3-lib}
)

# Include directories
target_include_directories(emulator-core PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/core
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
