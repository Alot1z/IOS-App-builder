package com.alot1z.androidemulator

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class EmulatorViewModel : ViewModel() {
    private val _emulatorState = MutableStateFlow<EmulatorState>(EmulatorState.Stopped)
    val emulatorState: StateFlow<EmulatorState> = _emulatorState

    init {
        // Initialize native libraries
        System.loadLibrary("emulator-core")
    }

    fun startEmulator() {
        viewModelScope.launch {
            _emulatorState.value = EmulatorState.Starting
            try {
                startEmulatorNative()
                _emulatorState.value = EmulatorState.Running
            } catch (e: Exception) {
                _emulatorState.value = EmulatorState.Error(e.message ?: "Unknown error")
            }
        }
    }

    fun pauseEmulator() {
        viewModelScope.launch {
            _emulatorState.value = EmulatorState.Paused
            pauseEmulatorNative()
        }
    }

    fun stopEmulator() {
        viewModelScope.launch {
            _emulatorState.value = EmulatorState.Stopped
            stopEmulatorNative()
        }
    }

    // Native method declarations
    private external fun startEmulatorNative()
    private external fun pauseEmulatorNative()
    private external fun stopEmulatorNative()
}

sealed class EmulatorState {
    object Stopped : EmulatorState()
    object Starting : EmulatorState()
    object Running : EmulatorState()
    object Paused : EmulatorState()
    data class Error(val message: String) : EmulatorState()
}
