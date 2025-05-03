package com.arthenica.ffmpegkit;

public class FFmpegKit {
    // Add static methods to satisfy imports
    public static FFmpegSession executeAsync(String[] arguments, Object completeCallback, Object logCallback, Object statisticsCallback) {
        return FFmpegSession.create(arguments, completeCallback, logCallback, statisticsCallback, LogRedirectionStrategy.NEVER_PRINT_LOGS);
    }
}