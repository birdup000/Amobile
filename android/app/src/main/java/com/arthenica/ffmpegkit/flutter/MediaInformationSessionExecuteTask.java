package com.arthenica.ffmpegkit.flutter;

import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodChannel;
import com.arthenica.ffmpegkit.MediaInformationSession;
import com.arthenica.ffmpegkit.FFmpegKitConfig;

public class MediaInformationSessionExecuteTask implements Runnable {
    private final MediaInformationSession mediaInformationSession;
    private final int timeout;
    private final FFmpegKitFlutterMethodResultHandler resultHandler;
    private final MethodChannel.Result result;

    public MediaInformationSessionExecuteTask(@NonNull final MediaInformationSession mediaInformationSession, final int timeout, @NonNull final FFmpegKitFlutterMethodResultHandler resultHandler, @NonNull final MethodChannel.Result result) {
        this.mediaInformationSession = mediaInformationSession;
        this.timeout = timeout;
        this.resultHandler = resultHandler;
        this.result = result;
    }

    @Override
    public void run() {
        try {
            // In a real implementation, this would execute the MediaInformation session
            // For our stub, we'll just return a success
            resultHandler.successAsync(result, mediaInformationSession.getSessionId());
        } catch (final Exception e) {
            resultHandler.errorAsync(result, "GET_MEDIA_INFORMATION_FAILED", "Getting media information failed: " + e.getMessage(), null);
        }
    }
}