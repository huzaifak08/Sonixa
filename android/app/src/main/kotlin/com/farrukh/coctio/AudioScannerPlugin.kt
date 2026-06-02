package com.farrukh.coctio

import android.content.ContentResolver
import android.content.Context
import android.provider.MediaStore
import android.media.session.MediaSession // ◄── Added native media session control mapping
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread

class AudioScannerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var mediaSession: MediaSession? = null // Handle container

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_channel")
        channel.setMethodCallHandler(this)

        // Force Android to recognize the active Media Audio Session Tag using your brand name
        try {
            mediaSession = MediaSession(flutterPluginBinding.applicationContext, "Sonixa").apply {
                isActive = true
            }
        } catch (e: Exception) {
            print("Failed to bind native MediaSession string token: $e")
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        mediaSession?.release() // Release resource token cleanly
        mediaSession = null
        context = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "getAudioFiles") {
            val ctx = context
            if (ctx == null) {
                result.error("CONTEXT_ERROR", "Application context is null", null)
                return
            }

            thread {
                try {
                    val audioList = getAudioFiles(ctx)
                    val handler = android.os.Handler(android.os.Looper.getMainLooper())
                    handler.post { result.success(audioList) }
                } catch (e: Exception) {
                    val handler = android.os.Handler(android.os.Looper.getMainLooper())
                    handler.post { result.error("DATABASE_ERROR", e.localizedMessage, null) }
                }
            }
        } else {
            result.notImplemented()
        }
    }

    private fun getAudioFiles(ctx: Context): List<Map<String, Any?>> {
        val audioList = mutableListOf<Map<String, Any?>>()
        val contentResolver: ContentResolver = ctx.contentResolver
        val uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI

        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.DISPLAY_NAME,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.ARTIST
        )

        val selection = "${MediaStore.Audio.Media.IS_MUSIC} != 0"
        val sortOrder = "${MediaStore.Audio.Media.DISPLAY_NAME} ASC"

        val cursor = contentResolver.query(uri, projection, selection, null, sortOrder)

        cursor?.use { c ->
            val idColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val nameColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.DISPLAY_NAME)
            val pathColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
            val durationColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
            val artistColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)

            while (c.moveToNext()) {
                val path = c.getString(pathColumn) ?: ""
                if (path.endsWith(".mp3", ignoreCase = true)) {
                    val audioMap = mapOf(
                        "id" to c.getLong(idColumn).toString(),
                        "title" to (c.getString(nameColumn) ?: "Unknown"),
                        "path" to path,
                        "duration" to c.getLong(durationColumn),
                        "artist" to (c.getString(artistColumn) ?: "Unknown")
                    )
                    audioList.add(audioMap)
                }
            }
        }
        return audioList
    }
}