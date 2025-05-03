package com.arthenica.ffmpegkit;

public class FFmpegSession extends Session {
    public static FFmpegSession create(String[] arguments, Object completeCallback, Object logCallback, Object statisticsCallback, Object logRedirectionStrategy) {
        return new FFmpegSession();
    }
    
    public java.util.List<Statistics> getAllStatistics(int timeout) {
        return new java.util.ArrayList<>();
    }
    
    public java.util.List<Statistics> getStatistics() {
        return new java.util.ArrayList<>();
    }
}