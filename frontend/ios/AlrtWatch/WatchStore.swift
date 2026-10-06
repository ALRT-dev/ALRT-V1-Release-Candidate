import Foundation
import WatchConnectivity

/// The watch's only source of truth: what the iPhone last said, and the
/// channel to ask the iPhone to act. The watch never calls the backend.
/// Published state is only ever changed on the main queue.
final class WatchStore: NSObject, ObservableObject {
  static let shared = WatchStore()

  @Published private(set) var status: WatchStatus?
  @Published private(set) var phoneReachable = false
  /// Navigation path (circle ids), so a notification can open a circle.
  @Published var path: [String] = []

  private let storageKey = "alrt.watch.status"
  private var started = false

  override init() {
    super.init()
    if let saved = UserDefaults.standard.dictionary(forKey: storageKey) {
      status = WatchStatus(saved)
    }
  }

  func start() {
    guard !started, WCSession.isSupported() else { return }
    started = true
    WCSession.default.delegate = self
    WCSession.default.activate()
  }

  func open(circleId: String) {
    path = [circleId]
  }

  func row(_ circleId: String) -> CircleRow? {
    status?.rows.first { $0.id == circleId }
  }

  /// Asks the iPhone to resend status (on opening the app).
  func requestFreshState() {
    start()
    guard WCSession.default.activationState == .activated, WCSession.default.isReachable else { return }
    WCSession.default.sendMessage(["action": "requestState"], replyHandler: { _ in }, errorHandler: { _ in })
  }

  // MARK: Actions

  /// "Check in to <circle>". No location is ever sent from the watch.
  func checkIn(_ row: CircleRow, key: String) async -> ActionOutcome {
    await ask(["action": "checkIn", "circleId": row.id, "circleName": row.name, "clientRequestId": key])
  }

  /// An SOS to everyone the backend says this circle's SOS would reach,
  /// with no location. Only called after the hold.
  func sendSos(_ row: CircleRow, key: String) async -> ActionOutcome {
    await ask(["action": "sos", "circleId": row.id, "circleName": row.name, "clientRequestId": key])
  }

  struct SosPreview: Equatable {
    let canSend: Bool
    let detail: String
  }

  /// Who the SOS would reach right now. Sends nothing.
  func sosPreview(_ row: CircleRow) async -> SosPreview? {
    guard let reply = await rawAsk(["action": "sosPreview", "circleId": row.id]) else { return nil }
    return SosPreview(
      canSend: reply["canSend"] as? Bool ?? false,
      detail: reply["detail"] as? String ?? "Open ALRT on your iPhone."
    )
  }

  private func ask(_ message: [String: Any]) async -> ActionOutcome {
    guard WCSession.default.activationState == .activated, WCSession.default.isReachable else {
      return .notSent(title: "Not sent", detail: "Your iPhone isn't connected. Keep it nearby, or use ALRT on your iPhone.")
    }
    guard let reply = await rawAsk(message) else { return .uncertain }
    let title = reply["title"] as? String ?? ""
    let detail = reply["detail"] as? String ?? ""
    if reply["ok"] as? Bool == true {
      return .done(title: title, detail: detail)
    }
    return .notSent(title: title.isEmpty ? "Not sent" : title, detail: detail)
  }

  /// One round trip to the iPhone. nil means no answer came back: the
  /// message may or may not have arrived.
  private func rawAsk(_ message: [String: Any]) async -> [String: Any]? {
    await withCheckedContinuation { continuation in
      var finished = false
      let finish: ([String: Any]?) -> Void = { value in
        DispatchQueue.main.async {
          guard !finished else { return }
          finished = true
          continuation.resume(returning: value)
        }
      }
      WCSession.default.sendMessage(message, replyHandler: { finish($0) }, errorHandler: { _ in finish(nil) })
      // Never spin forever on the wrist.
      DispatchQueue.main.asyncAfter(deadline: .now() + 30) { finish(nil) }
    }
  }

  // MARK: Status

  /// Main queue only.
  fileprivate func apply(_ context: [String: Any]) {
    guard !context.isEmpty else { return }
    let next = WatchStatus(context)
    if next.signedIn {
      UserDefaults.standard.set(context, forKey: storageKey)
    } else {
      // Signed out on the iPhone: forget every circle at once.
      UserDefaults.standard.removeObject(forKey: storageKey)
      path = []
    }
    status = next
  }
}

extension WatchStore: WCSessionDelegate {
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    let context = session.receivedApplicationContext
    let reachable = session.isReachable
    DispatchQueue.main.async {
      self.apply(context)
      self.phoneReachable = reachable
      self.requestFreshState()
    }
  }

  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
    DispatchQueue.main.async { self.apply(applicationContext) }
  }

  func sessionReachabilityDidChange(_ session: WCSession) {
    let reachable = session.isReachable
    DispatchQueue.main.async { self.phoneReachable = reachable }
  }
}
