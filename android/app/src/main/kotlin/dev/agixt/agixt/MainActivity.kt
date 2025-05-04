package dev.agixt.agixt

import android.os.Bundle
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import dev.agixt.agixt.cpp.Cpp
import android.content.Context

class MainActivity: FlutterActivity() {
    private val CHANNEL = "dev.agixt.agixt/channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Notifications.createNotificationChannels(this)
    }

     override fun onDestroy() {
        super.onDestroy()
        BackgroundService.stopService(this@MainActivity, null)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Cpp.init()

        GeneratedPluginRegistrant.registerWith(flutterEngine);
         MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "decodeLC3") {
                val data = call.argument<ByteArray>("data")
                if (data != null) {
                    val decodedData = Cpp.decodeLC3(data)
                    result.success(decodedData)
                } else {
                    result.error("INVALID_ARGUMENT", "Data is null", null)
                }
            } else {
                result.notImplemented()
            }
        }

        val binaryMessenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(binaryMessenger, "dev.agixt.agixt/background_service").apply {
            setMethodCallHandler { method, result ->
                if (method.method == "startService") {
                    val callbackRawHandle = method.arguments as Long
                    BackgroundService.startService(this@MainActivity, callbackRawHandle)
                    result.success(null)
                } else if (method.method == "stopService") {
                    println("inside kotlin hello2")
                    val callbackRawHandle = method.arguments as Long
                    BackgroundService.stopService(this@MainActivity, callbackRawHandle)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
        }

        MethodChannel(binaryMessenger, "dev.agixt.agixt/app_retain").apply {
            setMethodCallHandler { method, result ->
                if (method.method == "sendToBackground") {
                    moveTaskToBack(true)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
        }
        
        // Add a new method channel for wake word customization
        MethodChannel(binaryMessenger, "dev.agixt.agixt/wake_word_settings").apply {
            setMethodCallHandler { method, result ->
                if (method.method == "updateWakeWord") {
                    val newWakeWord = method.arguments as String
                    try {
                        // Get reference to any running BackgroundService instance
                        val intent = Intent(this@MainActivity, BackgroundService::class.java)
                        val service = peekService(intent)
                        
                        if (service != null) {
                            // Cast to BackgroundService and update the wake word
                            (service as BackgroundService).updateWakeWord(newWakeWord)
                            result.success(true)
                        } else {
                            // Service not running yet, store in shared preferences for next start
                            val prefs = getSharedPreferences("dev.agixt.agixt.WakeWordSettings", Context.MODE_PRIVATE)
                            prefs.edit().putString("wakeWord", newWakeWord).apply()
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        result.error("UPDATE_FAILED", "Failed to update wake word: ${e.message}", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
        }
    }

}
