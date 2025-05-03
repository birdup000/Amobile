import 'package:ffmpeg_kit_flutter_platform_interface/ffmpeg_kit_flutter_platform_interface.dart';
import 'dart:async';

class FFmpegKit {
  static Future<FFmpegSession> executeAsync(String command, {FFmpegSessionCompleteCallback? completeCallback, LogCallback? logCallback, StatisticsCallback? statisticsCallback}) async {
    // Return a dummy session
    return FFmpegSession(-1, -1, ReturnCode(-1));
  }

  static Future<FFmpegSession> execute(String command) async {
    // Return a dummy session
    return FFmpegSession(-1, -1, ReturnCode(-1));
  }

  static void cancel() {}
  static void cancelSession(int sessionId) {}
  static Future<void> cancelSessions(List<int> sessionIds) async {}
}

class ReturnCode {
  final int _value;
  
  const ReturnCode(this._value);
  
  bool get isSuccess => true;
  bool get isCancel => false;
  bool get isError => false;
  int get getValue => 0;
}

class FFmpegSession {
  final int _sessionId;
  final int _startTime;
  final ReturnCode _returnCode;
  
  FFmpegSession(this._sessionId, this._startTime, this._returnCode);
  
  int get getSessionId => _sessionId;
  String? get getAllLogsAsString => "";
  ReturnCode get getReturnCode => _returnCode;
}

class FFprobeKit {
  static Future<FFprobeSession> executeAsync(String command, {FFprobeSessionCompleteCallback? completeCallback, LogCallback? logCallback}) async {
    // Return a dummy session
    return FFprobeSession(-1, -1, ReturnCode(-1));
  }
  
  static Future<FFprobeSession> execute(String command) async {
    // Return a dummy session
    return FFprobeSession(-1, -1, ReturnCode(-1));
  }
  
  static Future<MediaInformationSession> getMediaInformationAsync(String path, {MediaInformationSessionCompleteCallback? completeCallback, LogCallback? logCallback}) async {
    // Return a dummy session
    return MediaInformationSession(-1, -1, ReturnCode(-1));
  }
  
  static Future<MediaInformationSession> getMediaInformation(String path) async {
    // Return a dummy session
    return MediaInformationSession(-1, -1, ReturnCode(-1));
  }
}

class FFprobeSession extends FFmpegSession {
  FFprobeSession(int sessionId, int startTime, ReturnCode returnCode) : super(sessionId, startTime, returnCode);
}

class MediaInformationSession extends FFprobeSession {
  MediaInformationSession(int sessionId, int startTime, ReturnCode returnCode) : super(sessionId, startTime, returnCode);
  
  MediaInformation? get getMediaInformation => null;
}

class MediaInformation {
  String? get getFormat => "N/A";
  String? get getFilename => "N/A";
  int? get getDuration => 0;
  int? get getBitrate => 0;
  List<StreamInformation> get getStreams => [];
}

class StreamInformation {
  String? get getIndex => "0";
  String? get getType => "audio";
  String? get getCodec => "N/A";
  String? get getFullFormat => "N/A";
  String? get getWidth => "0";
  String? get getHeight => "0";
  String? get getBitrate => "0";
  String? get getSampleRate => "0";
  String? get getSampleFormat => "N/A";
  String? get getChannelLayout => "N/A";
  String? get getSampleAspectRatio => "N/A";
  String? get getDisplayAspectRatio => "N/A";
  String? get getAverageFrameRate => "0";
  String? get getRealFrameRate => "0";
  String? get getTimeBase => "0";
  String? get getCodecTimeBase => "0";
}

typedef FFmpegSessionCompleteCallback = void Function(FFmpegSession session);
typedef FFprobeSessionCompleteCallback = void Function(FFprobeSession session);
typedef MediaInformationSessionCompleteCallback = void Function(MediaInformationSession session);
typedef LogCallback = void Function(Log log);
typedef StatisticsCallback = void Function(Statistics statistics);

class Log {
  final int _sessionId;
  final LogLevel _level;
  final String _message;
  
  Log(this._sessionId, this._level, this._message);
  
  int get getSessionId => _sessionId;
  LogLevel get getLevel => _level;
  String get getMessage => _message;
}

enum LogLevel {
  AV_LOG_QUIET,
  AV_LOG_PANIC,
  AV_LOG_FATAL,
  AV_LOG_ERROR,
  AV_LOG_WARNING,
  AV_LOG_INFO,
  AV_LOG_VERBOSE,
  AV_LOG_DEBUG,
  AV_LOG_TRACE
}

class Statistics {
  final int _sessionId;
  final int _videoFrameNumber;
  final double _videoFps;
  final double _videoQuality;
  final int _size;
  final double _time;
  final double _bitrate;
  final double _speed;
  
  Statistics(this._sessionId, this._videoFrameNumber, this._videoFps, this._videoQuality, this._size, this._time, this._bitrate, this._speed);
  
  int get getSessionId => _sessionId;
  int get getVideoFrameNumber => _videoFrameNumber;
  double get getVideoFps => _videoFps;
  double get getVideoQuality => _videoQuality;
  int get getSize => _size;
  double get getTime => _time;
  double get getBitrate => _bitrate;
  double get getSpeed => _speed;
}