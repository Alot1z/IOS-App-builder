package com.alot1z.androidemulator

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel

@Composable
fun EmulatorScreen(
    modifier: Modifier = Modifier,
    viewModel: EmulatorViewModel = viewModel()
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Emulator display area
        Box(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
        ) {
            // TODO: Add emulator surface view
        }
        
        // Controls
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            Button(onClick = { viewModel.startEmulator() }) {
                Text("Start")
            }
            Button(onClick = { viewModel.pauseEmulator() }) {
                Text("Pause")
            }
            Button(onClick = { viewModel.stopEmulator() }) {
                Text("Stop")
            }
        }
    }
}
