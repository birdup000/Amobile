package com.arthenica.ffmpegkit;

public class FFmpegKitConfig {
    public static void enableRedirection() {}
    public static void enableFFmpegSessionCompleteCallback(Object callback) {}
    public static void enableFFprobeSessionCompleteCallback(Object callback) {}
    public static void enableMediaInformationSessionCompleteCallback(Object callback) {}
    public static void enableLogCallback(Object callback) {}
    public static void enableStatisticsCallback(Object callback) {}
    public static Session getSession(long sessionId) { return null; }
    public static void ffmpegExecute(FFmpegSession session) {}
}