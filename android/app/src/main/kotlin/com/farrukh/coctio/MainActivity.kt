package com.farrukh.coctio
import android.content.ContentResolver
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread

class MainActivity: FlutterActivity() {
    private val channel = "flutter_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            if (call.method == "getAudioFiles") {
                // Querying MediaStore on the main UI thread can cause frame drops if the user has thousands of files.
                // We run it safely inside a background thread, then hop back to return the result.
                thread {
                    try {
                        val audioList = getAudioFiles()
                        runOnUiThread {
                            result.success(audioList)
                        }
                    } catch (e: Exception) {
                        runOnUiThread {
                            result.error("DATABASE_ERROR", e.localizedMessage, null)
                        }
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getAudioFiles(): List<Map<String, Any?>> {
        val audioList = mutableListOf<Map<String, Any?>>()
        val contentResolver: ContentResolver = contentResolver

        // Target the external shared storage database
        val uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI

        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.DISPLAY_NAME,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.ARTIST
        )

        // Filter out non-music sounds like notifications, UI clicks, system ringtones
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

                // Enforce .mp3 check manually if you don't want formats like .wav, .m4a or .ogg
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