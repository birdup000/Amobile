import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var pendingToken: String? = nil
  
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
      
      // Register method channel for OAuth callback handling
      let oauthChannel = FlutterMethodChannel(name: "dev.agixt.agixt/oauth_callback", 
                                             binaryMessenger: controller.binaryMessenger)
      oauthChannel.setMethodCallHandler { [weak self] (call, result) in
        if call.method == "checkPendingToken" {
          if let token = self?.pendingToken {
            result(["token": token])
            self?.pendingToken = nil
          } else {
            result(nil)
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle incoming URLs (including OAuth callbacks)
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // Check if this is our OAuth callback URL
    if url.scheme == "agixt" && url.host == "callback" {
      // Extract token from URL query parameters
      if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
         let queryItems = components.queryItems,
         let tokenItem = queryItems.first(where: { $0.name == "token" }),
         let token = tokenItem.value {
        
        print("OAuth callback received with token")
        
        // Send token to Flutter if it's already initialized
        if let controller = window?.rootViewController as? FlutterViewController {
          let channel = FlutterMethodChannel(name: "dev.agixt.agixt/oauth_callback", 
                                          binaryMessenger: controller.binaryMessenger)
          channel.invokeMethod("handleOAuthCallback", arguments: ["token": token])
        } else {
          // Store token for later if Flutter isn't ready yet
          pendingToken = token
        }
        
        return true
      }
    }
    
    // Let Flutter plugins handle the URL
    return super.application(app, open: url, options: options)
  }
}
