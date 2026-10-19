import Foundation
import WatchConnectivity

/// The same JSON the phone's home-screen widget draws from.
struct Glance: Decodable {
    struct Alert: Decodable {
        let band: String
        let severityLabel: String
        let title: String
        let area: String?
        let distance: String?
        let time: String?
    }

    let state: String?
    let updatedLabel: String?
    let activeCount: Int?
    let primary: Alert?
}

/// Receives the glance from the phone (WatchConnectivity application context)
/// and keeps the last one so the app opens instantly. Read-only: nothing here
/// sends an SOS, a message or a location.
final class GlanceModel: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = GlanceModel()

    @Published private(set) var glance: Glance?
    @Published private(set) var hasData = false

    private let storeKey = "alrt_watch_payload"

    override init() {
        super.init()
        if let saved = UserDefaults.standard.string(forKey: storeKey) {
            apply(saved, persist: false)
        }
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    private func apply(_ json: String, persist: Bool = true) {
        guard let data = json.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(Glance.self, from: data) else { return }
        if persist { UserDefaults.standard.set(json, forKey: storeKey) }
        DispatchQueue.main.async {
            self.glance = decoded
            self.hasData = true
        }
    }

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if let json = session.receivedApplicationContext["payload"] as? String {
            apply(json)
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        if let json = applicationContext["payload"] as? String {
            apply(json)
        }
    }
}
