package com.arthenica.ffmpegkit;

public class MediaInformationSession extends FFprobeSession {
    public static MediaInformationSession create(String[] arguments, Object completeCallback, Object logCallback) {
        return new MediaInformationSession();
    }
    
    public MediaInformation getMediaInformation() {
        return null;
    }
}