import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Set up Flutter binary messenger for communication
    let controller = window?.rootViewController as? FlutterViewController
    if let controller = controller {
      FlutterBinaryMessengerRelay.shared.setBinaryMessenger(controller.binaryMessenger)
      
      // Register method channel for wake word customization
      let wakeWordChannel = FlutterMethodChannel(name: "dev.agixt.agixt/ios_wake_word", 
                                               binaryMessenger: controller.binaryMessenger)
      wakeWordChannel.setMethodCallHandler { (call, result) in
        if call.method == "updateWakeWord" {
          if let args = call.arguments as? [String: Any],
             let wakeWord = args["wakeWord"] as? String {
            // Update the wake word in SpeechStreamRecognizer
            SpeechStreamRecognizer.shared.updateWakeWord(wakeWord)
            result(true)
          } else {
            result(FlutterError(code: "INVALID_ARGUMENTS", 
                              message: "Missing wakeWord parameter", 
                              details: nil))
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
