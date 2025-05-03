package com.arthenica.ffmpegkit.flutter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.MethodChannel;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class FFmpegKitFlutterMethodResultHandler {
    private static final ExecutorService EXECUTOR_SERVICE = Executors.newSingleThreadExecutor();

    public void successAsync(@NonNull final MethodChannel.Result result, @Nullable final Object object) {
        EXECUTOR_SERVICE.execute(() -> {
            result.success(object);
        });
    }

    public void errorAsync(@NonNull final MethodChannel.Result result, @NonNull final String errorCode, @NonNull final String errorMessage, @Nullable final Object data) {
        EXECUTOR_SERVICE.execute(() -> {
            result.error(errorCode, errorMessage, data);
        });
    }
}