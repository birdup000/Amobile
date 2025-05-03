package com.arthenica.ffmpegkit.flutter;

import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodChannel;
import com.arthenica.ffmpegkit.FFprobeSession;
import com.arthenica.ffmpegkit.FFmpegKitConfig;

public class FFprobeSessionExecuteTask implements Runnable {
    private final FFprobeSession ffprobeSession;
    private final FFmpegKitFlutterMethodResultHandler resultHandler;
    private final MethodChannel.Result result;

    public FFprobeSessionExecuteTask(@NonNull final FFprobeSession ffprobeSession, @NonNull final FFmpegKitFlutterMethodResultHandler resultHandler, @NonNull final MethodChannel.Result result) {
        this.ffprobeSession = ffprobeSession;
        this.resultHandler = resultHandler;
        this.result = result;
    }

    @Override
    public void run() {
        try {
            // In a real implementation, this would execute the FFprobe session
            // For our stub, we'll just return a success
            resultHandler.successAsync(result, ffprobeSession.getSessionId());
        } catch (final Exception e) {
            resultHandler.errorAsync(result, "EXECUTE_FFPROBE_SESSION_FAILED", "FFprobe session execute failed: " + e.getMessage(), null);
        }
    }
}