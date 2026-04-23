import UIKit
import Flutter
import Photos

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let mediaChannel = FlutterMethodChannel(
        name: "chat_uikit_demo/media",
        binaryMessenger: controller.binaryMessenger
      )
      mediaChannel.setMethodCallHandler { call, result in
        guard call.method == "saveImageToGallery" else {
          result(FlutterMethodNotImplemented)
          return
        }

        guard
          let arguments = call.arguments as? [String: Any],
          let path = arguments["path"] as? String,
          !path.isEmpty
        else {
          result(
            FlutterError(
              code: "invalid_path",
              message: "Image path is empty.",
              details: nil
            )
          )
          return
        }

        self.saveImageToGallery(path: path, result: result)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func saveImageToGallery(path: String, result: @escaping FlutterResult) {
    let fileURL = URL(fileURLWithPath: path)
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      result(false)
      return
    }

    PHPhotoLibrary.shared().performChanges({
      PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileURL)
    }) { success, _ in
      DispatchQueue.main.async {
        result(success)
      }
    }
  }
}
