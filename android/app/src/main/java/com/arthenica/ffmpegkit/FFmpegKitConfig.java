package com.arthenica.ffmpegkit;

import android.content.Context;
import java.util.List;
import java.util.Map;

public class FFmpegKitConfig {
    public static void enableRedirection() {}
    public static void disableRedirection() {}
    
    public static void enableFFmpegSessionCompleteCallback(Object callback) {}
    public static void enableFFprobeSessionCompleteCallback(Object callback) {}
    public static void enableMediaInformationSessionCompleteCallback(Object callback) {}
    public static void enableLogCallback(Object callback) {}
    public static void enableStatisticsCallback(Object callback) {}
    
    public static Session getSession(long sessionId) { return new Session(); }
    public static void ffmpegExecute(FFmpegSession session) {}
    public static void asyncFFmpegExecute(FFmpegSession session) {}
    public static void asyncFFprobeExecute(FFprobeSession session) {}
    public static void asyncGetMediaInformationExecute(MediaInformationSession session, int timeout) {}
    
    public static Level getLogLevel() { return Level.AV_LOG_INFO; }
    public static void setLogLevel(Level level) {}
    
    public static int getSessionHistorySize() { return 10; }
    public static void setSessionHistorySize(Integer size) {}
    
    public static Session getLastSession() { return new Session(); }
    public static Session getLastCompletedSession() { return new Session(); }
    public static List<Session> getSessions() { return new java.util.ArrayList<>(); }
    public static void clearSessions() {}
    public static List<Session> getSessionsByState(SessionState state) { return new java.util.ArrayList<>(); }
    
    public static void setFontconfigConfigurationPath(String path) {}
    public static void setFontDirectory(Context context, String fontDirectoryPath, Map<String, String> fontNameMapping) {}
    public static void setFontDirectoryList(Context context, List<String> fontDirectoryList, Map<String, String> fontNameMapping) {}
    
    public static String registerNewFFmpegPipe(Context context) { return "pipe:"; }
    public static void closeFFmpegPipe(String ffmpegPipePath) {}
    
    public static String getFFmpegVersion() { return "4.4"; }
    public static boolean isLTSBuild() { return true; }
    public static String getBuildDate() { return "2023-01-01"; }
    
    public static void setEnvironmentVariable(String name, String value) {}
    public static void ignoreSignal(Signal signal) {}
}