import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Icono de Dart → conjunto alternativo del catálogo (nil = AppIcon).
  private static let alternateIcons: [String: String?] = [
    "classic": nil,
    "crown": "AppIconCrown",
    "yarn": "AppIconYarn",
  ]

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AppIconChannel") {
      registerAppIconChannel(messenger: registrar.messenger())
    }
  }

  private func registerAppIconChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "constanza/app_icon", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "current":
        let name = UIApplication.shared.alternateIconName
        let id = Self.alternateIcons.first { $0.value == name }?.key ?? "classic"
        result(id)
      case "set":
        guard
          let args = call.arguments as? [String: Any],
          let id = args["id"] as? String,
          let iconName = Self.alternateIcons[id]
        else {
          result(FlutterError(code: "unknown_icon", message: "Icono desconocido", details: nil))
          return
        }
        guard UIApplication.shared.supportsAlternateIcons else {
          result(FlutterError(code: "unsupported", message: nil, details: nil))
          return
        }
        UIApplication.shared.setAlternateIconName(iconName) { error in
          if let error = error {
            result(FlutterError(code: "failed", message: error.localizedDescription, details: nil))
          } else {
            result(nil)
          }
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
