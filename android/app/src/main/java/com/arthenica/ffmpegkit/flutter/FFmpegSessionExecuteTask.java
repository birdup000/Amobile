package com.arthenica.ffmpegkit.flutter;

import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodChannel;
import com.arthenica.ffmpegkit.FFmpegSession;
import com.arthenica.ffmpegkit.FFmpegKitConfig;

public class FFmpegSessionExecuteTask implements Runnable {
    private final FFmpegSession ffmpegSession;
    private final FFmpegKitFlutterMethodResultHandler resultHandler;
    private final MethodChannel.Result result;

    public FFmpegSessionExecuteTask(@NonNull final FFmpegSession ffmpegSession, @NonNull final FFmpegKitFlutterMethodResultHandler resultHandler, @NonNull final MethodChannel.Result result) {
        this.ffmpegSession = ffmpegSession;
        this.resultHandler = resultHandler;
        this.result = result;
    }

    @Override
    public void run() {
        try {
            FFmpegKitConfig.ffmpegExecute(ffmpegSession);
            resultHandler.successAsync(result, ffmpegSession.getSessionId());
        } catch (final Exception e) {
            resultHandler.errorAsync(result, "EXECUTE_FFMPEG_SESSION_FAILED", "FFmpeg session execute failed: " + e.getMessage(), null);
        }
    }
}