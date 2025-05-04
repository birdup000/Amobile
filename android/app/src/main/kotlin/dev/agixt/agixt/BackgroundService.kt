package dev.agixt.agixt

import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.IBinder
import android.util.Log
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.view.FlutterCallbackInformation
import io.flutter.embedding.engine.loader.FlutterLoader
import android.speech.SpeechRecognizer
import android.speech.RecognitionListener
import android.content.ComponentName

class BackgroundService : Service(), LifecycleDetector.Listener {

    private var flutterEngine: FlutterEngine? = null
    private val flutterLoader = FlutterLoader()
    private var speechRecognizer: SpeechRecognizer? = null
    private val wakeWord = "agixt"

    override fun onCreate() {
        super.onCreate()

        // Initialize FlutterLoader if it hasn't been initialized yet
        if (!flutterLoader.initialized()) {
            flutterLoader.startInitialization(applicationContext)
            flutterLoader.ensureInitializationComplete(applicationContext, null)
        }

        val notification = Notifications.buildForegroundNotification(this)
        startForeground(Notifications.NOTIFICATION_ID_BACKGROUND_SERVICE, notification)

        LifecycleDetector.listener = this

        initializeWakeWordDetection()
    }


    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        intent?.getLongExtra(KEY_CALLBACK_RAW_HANDLE, -1)?.let { callbackRawHandle ->
            if (callbackRawHandle != -1L) setCallbackRawHandle(callbackRawHandle)
        }

        if (!LifecycleDetector.isActivityRunning) {
            startFlutterNativeView()
        }

        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        LifecycleDetector.listener = null
    }

    override fun onBind(intent: Intent): IBinder? = null

    override fun onFlutterActivityCreated() {
        stopFlutterNativeView()
    }

    override fun onFlutterActivityDestroyed() {
        startFlutterNativeView()
    }

    private fun startFlutterNativeView() {
        if (flutterEngine != null) return

        Log.i("BackgroundService", "Starting FlutterEngine")

        getCallbackRawHandle()?.let { callbackRawHandle ->
            flutterEngine = FlutterEngine(this).also { engine ->
                val callbackInformation =
                    FlutterCallbackInformation.lookupCallbackInformation(callbackRawHandle)

                engine.dartExecutor.executeDartCallback(
                    DartExecutor.DartCallback(
                        assets,
                        flutterLoader.findAppBundlePath(),
                        callbackInformation
                    )
                )
            }
        }
    }

    private fun stopFlutterNativeView() {
        Log.i("BackgroundService", "Stopping FlutterEngine")
        flutterEngine?.destroy()
        flutterEngine = null
    }

    private fun getCallbackRawHandle(): Long? {
        val prefs = getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        val callbackRawHandle = prefs.getLong(KEY_CALLBACK_RAW_HANDLE, -1)
        return if (callbackRawHandle != -1L) callbackRawHandle else null
    }

    private fun setCallbackRawHandle(handle: Long) {
        val prefs = getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        prefs.edit().putLong(KEY_CALLBACK_RAW_HANDLE, handle).apply()
    }

    private fun initializeWakeWordDetection() {
        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this, ComponentName(this, BackgroundService::class.java))
        speechRecognizer?.setRecognitionListener(object : RecognitionListener {
            override fun onResults(results: Bundle?) {
                val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                matches?.let {
                    for (result in it) {
                        if (result.contains(wakeWord, ignoreCase = true)) {
                            triggerAGiXTWorkflow(result)
                            break
                        }
                    }
                }
            }

            override fun onError(error: Int) {
                Log.e("WakeWord", "Error: $error")
            }

            // Other overridden methods omitted for brevity
        })
    }

    private fun triggerAGiXTWorkflow(transcription: String) {
        Log.i("WakeWord", "Wake word detected: $transcription")
        // Logic to send transcription to AGiXT workflow
    }

    companion object {
        private const val SHARED_PREFERENCES_NAME = "dev.agixt.agixt.BackgroundService"

        private var callbackRawHandle: Long? = null;

        private const val KEY_CALLBACK_RAW_HANDLE = "callbackRawHandle"

        fun startService(context: Context, callbackRawHandle: Long) {
            this.callbackRawHandle = callbackRawHandle;
            val intent: Intent;

            intent = Intent(context, BackgroundService::class.java).apply {
                putExtra(KEY_CALLBACK_RAW_HANDLE, callbackRawHandle)
            }
            ContextCompat.startForegroundService(context, intent)
        }

        fun stopService(context: Context, callbackRawHandle: Long? = null) {
            val intent: Intent;
            val cbr = this.callbackRawHandle;

            intent = Intent(context, BackgroundService::class.java).apply {
                putExtra(KEY_CALLBACK_RAW_HANDLE, cbr)
            }
            context.stopService(intent);
        }


    }

}