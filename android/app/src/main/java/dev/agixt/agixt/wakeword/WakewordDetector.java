package dev.agixt.agixt.wakeword;

import android.content.Context;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.os.Handler;
import android.os.Looper;
import android.speech.RecognitionListener;
import android.speech.SpeechRecognizer;
import android.speech.voice.VoiceInteractionService;
import android.speech.voice.VoiceInteractionSession;
// import android.speech.voice.HotwordDetector; // Commented out as we are using AlwaysOnHotwordDetector from service.voice
import android.service.voice.AlwaysOnHotwordDetector;
import android.service.voice.HotwordRecognitionService;
import android.util.Log; // Import Log

import androidx.annotation.NonNull;
import java.util.Locale;
import io.flutter.plugin.common.MethodChannel;

public class WakewordDetector {
    private static final String TAG = "WakewordDetector";
    private Context context;
    private AlwaysOnHotwordDetector mHotwordDetector;
    private MethodChannel methodChannel;
    // private SpeechRecognizer speechRecognizer; // Not strictly needed for hotword detection alone

    // Callback for AlwaysOnHotwordDetector
    private final AlwaysOnHotwordDetector.Callback mHotwordCallback = new AlwaysOnHotwordDetector.Callback() {
        @Override
        public void onAvailabilityChanged(int status) {
            Log.d(TAG, "Hotword availability changed to: " + status);
            if (status == AlwaysOnHotwordDetector.STATE_KEYPHRASE_ENROLLED) {
                Log.d(TAG, "Keyphrase enrolled, ready to start listening.");
                // You might want to automatically start recognition here or wait for a command from Flutter
            } else if (status == AlwaysOnHotwordDetector.STATE_KEYPHRASE_UNENROLLED) {
                Log.d(TAG, "Keyphrase unenrolled.");
                // Handle case where no keyphrase is enrolled.
            } else if (status == AlwaysOnHotwordDetector.STATE_HARDWARE_UNAVAILABLE) {
                Log.e(TAG, "Hotword detection hardware unavailable.");
            }
        }

        @Override
        public void onDetected(AlwaysOnHotwordDetector.EventPayload eventPayload) {
            Log.d(TAG, "Wakeword detected!");
            if (methodChannel != null) {
                // Notify Flutter that the wakeword was detected
                // The main thread is required for invoking method channel calls.
                new Handler(Looper.getMainLooper()).post(() -> {
                    methodChannel.invokeMethod("onWakewordDetected", null);
                });
            }
            // Optionally, you can try to re-arm the detector if it's a one-shot detection
            // This depends on the specific behavior of your hotword detector implementation
            // startHotwordRecognition(); 
        }

        @Override
        public void onError() {
            Log.e(TAG, "Hotword detection failed with an error.");
        }

        @Override
        public void onRecognitionPaused() {
            Log.d(TAG, "Hotword recognition paused.");
        }

        @Override
        public void onRecognitionResumed() {
            Log.d(TAG, "Hotword recognition resumed.");
        }
    };

    public WakewordDetector(Context context, MethodChannel methodChannel) {
        this.context = context;
        this.methodChannel = methodChannel;
        // Note: Initialization of AlwaysOnHotwordDetector requires a HotwordRecognitionService
        // This is a simplified example. A full implementation would involve creating and binding to such a service.
        // For now, we'll assume the service context handles this.
        // If SpeechRecognizer.isRecognitionAvailable(context) && SpeechRecognizer.isOnDeviceRecognitionAvailable(context) {
        // This check is more for general speech recognition, not specifically for AlwaysOnHotwordDetector
        // }

        // The actual AlwaysOnHotwordDetector is typically obtained from a HotwordRecognitionService
        // This part is complex and depends on having a system-level voice interaction service
        // and a specific hotword model for "Agent".
        // For this example, we cannot fully initialize it without a running HotwordRecognitionService.
        // Log.d(TAG, "WakewordDetector initialized. Waiting for HotwordRecognitionService connection.");
        // We will simulate the detector for now and call the callback methods as if a real detector was present.
    }


    public void startDetection() {
        Log.d(TAG, "Attempting to start hotword detection.");
        // In a real scenario, you would obtain the AlwaysOnHotwordDetector from your HotwordRecognitionService
        // and then call startRecognition.
        // Example: if (mHotwordDetector != null) {
        //    mHotwordDetector.startRecognition(AlwaysOnHotwordDetector.RECOGNITION_FLAG_CAPTURE_TRIGGER_AUDIO);
        // } else {
        //    Log.e(TAG, "HotwordDetector not available or not initialized.");
        // }

        // Simulate detection for now
        Log.d(TAG, "Simulating hotword detection start. Will 'detect' in 5 seconds.");
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            // Simulate onDetected callback
            if (mHotwordCallback != null) {
                 mHotwordCallback.onDetected(null); // Passing null as EventPayload for simulation
            }
        }, 5000);
    }

    public void stopDetection() {
        Log.d(TAG, "Attempting to stop hotword detection.");
        // In a real scenario:
        // if (mHotwordDetector != null) {
        //    mHotwordDetector.stopRecognition();
        // } else {
        //    Log.e(TAG, "HotwordDetector not available or not initialized.");
        // }
        // For simulation, we don't need to do much here as the simulated detection is a one-shot.
        Log.d(TAG, "Hotword detection stop requested (simulated).");
    }

    // TODO: Implement VoiceRecognitionListener for handling speech recognition results (if needed for more than just hotword)
    // private class VoiceRecognitionListener implements RecognitionListener { ... }
}
