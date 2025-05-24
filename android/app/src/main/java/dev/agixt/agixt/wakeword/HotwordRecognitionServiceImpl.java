package dev.agixt.agixt.wakeword;

import android.content.Intent;
import android.os.Bundle;
import android.service.voice.HotwordRecognitionService;
import android.service.voice.AlwaysOnHotwordDetector;
import android.util.Log;

import java.util.Locale;

public class HotwordRecognitionServiceImpl extends HotwordRecognitionService {
    private static final String TAG = "HotwordRecognitionSvc";
    private AlwaysOnHotwordDetector mHotwordDetector;

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "Service onCreate");
    }

    @Override
    public void onHotwordDetectionServiceInitialized() {
        super.onHotwordDetectionServiceInitialized();
        Log.d(TAG, "onHotwordDetectionServiceInitialized");
        // This is where you would typically initialize your AlwaysOnHotwordDetector
        // For this example, we are not fully implementing it due to the complexity
        // of managing enrollment and specific hardware/OS support.

        // Example of how you might try to create it, assuming a keyphrase and locale:
        /*
        try {
            mHotwordDetector = createAlwaysOnHotwordDetector(
                    "Agent", // The keyphrase to listen for
                    Locale.getDefault(), // The locale of the keyphrase
                    new AlwaysOnHotwordDetector.Callback() {
                        @Override
                        public void onAvailabilityChanged(int status) {
                            Log.d(TAG, "HotwordDetector availability: " + status);
                            // You might want to update the detector state here
                        }

                        @Override
                        public void onDetected(AlwaysOnHotwordDetector.EventPayload eventPayload) {
                            Log.d(TAG, "Hotword Detected!");
                            // This is where you would notify your app, perhaps via a broadcast or by calling a method
                            // on a bound service or activity.
                            // For simplicity, we're just logging here.
                            // In a real app, you'd likely want to start an activity or send a message to Flutter.
                        }

                        @Override
                        public void onError() {
                            Log.e(TAG, "Hotword Detection Error");
                        }

                        @Override
                        public void onRecognitionPaused() {
                            Log.d(TAG, "Hotword Recognition Paused");
                        }

                        @Override
                        public void onRecognitionResumed() {
                            Log.d(TAG, "Hotword Recognition Resumed");
                        }
                    });
        } catch (Exception e) {
            Log.e(TAG, "Failed to create AlwaysOnHotwordDetector", e);
        }
        */
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "Service onStartCommand");
        // The service is typically started by the system.
        // You might receive commands here to start or stop listening if you design it that way.
        return START_STICKY; // Or another appropriate return value
    }

    @Override
    public void onDestroy() {
        Log.d(TAG, "Service onDestroy");
        if (mHotwordDetector != null) {
            // mHotwordDetector.stopRecognition(); // Example cleanup
            mHotwordDetector = null;
        }
        super.onDestroy();
    }

    // You might need to implement onUpdateState, onGenericMotionEvent, etc.,
    // depending on the complexity of your voice interaction setup.
}
