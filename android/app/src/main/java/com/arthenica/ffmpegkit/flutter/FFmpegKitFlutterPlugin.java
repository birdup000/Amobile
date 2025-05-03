package com.arthenica.ffmpegkit.flutter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;

public class FFmpegKitFlutterPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;
    
    @Override
    public void onAttachedToEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "com.arthenica.ffmpeg.kit");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        // This is a stub implementation that just returns empty or default values
        switch (call.method) {
            case "getPlatform":
                result.success("android");
                break;
            case "getFFmpegVersion":
            case "getVersion":
                result.success("6.0");
                break;
            default:
                // For any other method, return an empty success to prevent crashes
                result.success(null);
                break;
        }
    }
}