package com.farrukh.coctio

import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity: AudioServiceActivity() {
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Manually inject your custom scanner plugin into the Flutter Engine instance
        flutterEngine.plugins.add(AudioScannerPlugin())
    }
}