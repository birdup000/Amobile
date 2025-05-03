package com.arthenica.ffmpegkit;

public class FFprobeSession extends Session {
    public static FFprobeSession create(String[] arguments, Object completeCallback, Object logCallback, Object logRedirectionStrategy) {
        return new FFprobeSession();
    }
}