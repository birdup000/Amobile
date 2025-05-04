import Flutter

// Helper class to relay Flutter binary messages
class FlutterBinaryMessengerRelay {
    static let shared = FlutterBinaryMessengerRelay()
    private var binaryMessenger: FlutterBinaryMessenger?
    
    func setBinaryMessenger(_ messenger: FlutterBinaryMessenger) {
        binaryMessenger = messenger
    }
}

extension FlutterBinaryMessengerRelay: FlutterBinaryMessenger {
    func send(onChannel channel: String, message: Data?, binaryReply: FlutterBinaryReply? = nil) {
        binaryMessenger?.send(onChannel: channel, message: message, binaryReply: binaryReply)
    }
    
    func send(onChannel channel: String, message: Data?) -> FlutterBinaryMessengerConnection {
        return binaryMessenger?.send(onChannel: channel, message: message) ?? 0
    }
    
    func setMessageHandlerOnChannel(_ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler? = nil) -> FlutterBinaryMessengerConnection {
        return binaryMessenger?.setMessageHandlerOnChannel(channel, binaryMessageHandler: handler) ?? 0
    }
}