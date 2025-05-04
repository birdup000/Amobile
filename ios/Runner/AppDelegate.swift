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
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
