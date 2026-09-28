import CoreMotion
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

  private let pedometerChannel = PedometerChannel()

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AppIconChannel") {
      registerAppIconChannel(messenger: registrar.messenger())
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "PedometerChannel") {
      pedometerChannel.register(messenger: registrar.messenger())
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

/// Contador de pasos nativo (Core Motion) para la herramienta Pasos.
///
/// - `constanza/pedometer` (métodos): `isAvailable`, `permissionStatus`,
///   `requestPermission` y `query(fromMs, toMs)` → {steps, distanceMeters}.
/// - `constanza/pedometer/updates` (eventos): pasos acumulados desde el
///   instante `fromMs` (normalmente el inicio del día), incluidos los dados
///   con la app cerrada, porque Core Motion los conserva siete días.
final class PedometerChannel: NSObject, FlutterStreamHandler {
  private let pedometer = CMPedometer()

  func register(messenger: FlutterBinaryMessenger) {
    let methods = FlutterMethodChannel(name: "constanza/pedometer", binaryMessenger: messenger)
    methods.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result)
    }
    let events = FlutterEventChannel(name: "constanza/pedometer/updates", binaryMessenger: messenger)
    events.setStreamHandler(self)
  }

  private func handle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    switch call.method {
    case "isAvailable":
      result(CMPedometer.isStepCountingAvailable())
    case "permissionStatus":
      result(Self.status())
    case "requestPermission":
      // El sistema pregunta la primera vez que se consulta el podómetro.
      let now = Date()
      pedometer.queryPedometerData(from: now.addingTimeInterval(-60), to: now) { _, _ in
        DispatchQueue.main.async { result(Self.status()) }
      }
    case "query":
      guard
        let args = call.arguments as? [String: Any],
        let fromMs = (args["fromMs"] as? NSNumber)?.doubleValue,
        let toMs = (args["toMs"] as? NSNumber)?.doubleValue
      else {
        result(FlutterError(code: "bad_args", message: "fromMs y toMs requeridos", details: nil))
        return
      }
      pedometer.queryPedometerData(
        from: Date(timeIntervalSince1970: fromMs / 1000),
        to: Date(timeIntervalSince1970: toMs / 1000)
      ) { data, error in
        DispatchQueue.main.async {
          if let error = error {
            result(FlutterError(code: "query_failed", message: error.localizedDescription, details: nil))
          } else {
            result(Self.payload(data))
          }
        }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private static func status() -> String {
    switch CMPedometer.authorizationStatus() {
    case .authorized: return "granted"
    case .denied, .restricted: return "denied"
    case .notDetermined: return "notDetermined"
    @unknown default: return "notDetermined"
    }
  }

  private static func payload(_ data: CMPedometerData?) -> [String: Any] {
    var payload: [String: Any] = [
      "steps": data?.numberOfSteps.intValue ?? 0,
      "atMs": Date().timeIntervalSince1970 * 1000,
    ]
    if let distance = data?.distance?.doubleValue {
      payload["distanceMeters"] = distance
    }
    return payload
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    guard
      let args = arguments as? [String: Any],
      let fromMs = (args["fromMs"] as? NSNumber)?.doubleValue
    else {
      return FlutterError(code: "bad_args", message: "fromMs requerido", details: nil)
    }
    pedometer.startUpdates(from: Date(timeIntervalSince1970: fromMs / 1000)) { data, error in
      DispatchQueue.main.async {
        if let error = error {
          events(FlutterError(code: "updates_failed", message: error.localizedDescription, details: nil))
        } else {
          events(Self.payload(data))
        }
      }
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    pedometer.stopUpdates()
    return nil
  }
}
