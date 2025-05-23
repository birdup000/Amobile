package dev.agixt.agixt

import android.os.Bundle
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import dev.agixt.agixt.cpp.Cpp
import android.content.Context
import android.content.Intent
import android.app.Service
import android.content.ContextWrapper
import android.app.ActivityManager
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.net.Uri
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "dev.agixt.agixt/channel"
    private val PERMISSION_REQUEST_CODE = 100
    private val TAG = "MainActivity"
    private var methodChannelInitialized = false
    private var pendingToken: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Notifications.createNotificationChannels(this)
        
        // Request microphone permission at startup
        requestMicrophonePermission()
        
        // Handle intent when app is first launched
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        intent?.let {
            // Check if the intent is from OAuth callback
            if (Intent.ACTION_VIEW == it.action) {
                val uri = it.data
                if (uri != null && uri.scheme == "agixt" && uri.host == "callback") {
                    // Extract the JWT token from the URI
                    val token = uri.getQueryParameter("token")
                    if (!token.isNullOrEmpty()) {
                        Log.d(TAG, "OAuth callback received with token")
                        if (methodChannelInitialized) {
                            // If Flutter is already initialized, send the token immediately
                            sendTokenToFlutter(token)
                        } else {
                            // Otherwise, store it for later sending once Flutter is initialized
                            pendingToken = token
                        }
                    }
                }
            }
        }
    }

    private fun sendTokenToFlutter(token: String) {
        val binaryMessenger = flutterEngine?.dartExecutor?.binaryMessenger
        if (binaryMessenger != null) {
            MethodChannel(binaryMessenger, "dev.agixt.agixt/oauth_callback").invokeMethod(
                "handleOAuthCallback",
                mapOf("token" to token),
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        Log.d(TAG, "Token sent to Flutter successfully")
                    }

                    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                        Log.e(TAG, "Error sending token to Flutter: $errorCode - $errorMessage")
                    }

                    override fun notImplemented() {
                        Log.e(TAG, "Method not implemented in Flutter")
                    }
                }
            )
        }
    }

    private fun requestMicrophonePermission() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) 
            != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.RECORD_AUDIO),
                PERMISSION_REQUEST_CODE
            )
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission granted, can now use microphone for wake word detection
            } else {
                // Permission denied, may need to show explanation to user
            }
        }
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
                        // Check if service is running
                        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                        val serviceRunning = activityManager.getRunningServices(Integer.MAX_VALUE)
                            .any { it.service.className == BackgroundService::class.java.name }
                        
                        if (serviceRunning) {
                            // Service is running, send a broadcast to update the wake word
                            val intent = Intent("dev.agixt.agixt.UPDATE_WAKE_WORD")
                            intent.putExtra("wakeWord", newWakeWord)
                            sendBroadcast(intent)
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
        
        // Add a method channel for handling OAuth callback
        MethodChannel(binaryMessenger, "dev.agixt.agixt/oauth_callback").apply {
            setMethodCallHandler { method, result ->
                if (method.method == "checkPendingToken") {
                    // If there's a pending token from a deep link that was received before Flutter initialized
                    pendingToken?.let { token ->
                        result.success(mapOf("token" to token))
                        pendingToken = null // Clear the token after sending it
                    } ?: result.success(null)
                } else {
                    result.notImplemented()
                }
            }
        }
        
        // Mark that the method channels are initialized
        methodChannelInitialized = true
        
        // Check if we have a pending token to send
        pendingToken?.let { token ->
            sendTokenToFlutter(token)
            pendingToken = null
        }
    }
}
