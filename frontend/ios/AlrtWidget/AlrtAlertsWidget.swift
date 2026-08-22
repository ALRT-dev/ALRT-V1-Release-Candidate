import WidgetKit
import SwiftUI

// MARK: - Shared contract (keep in sync with Dart `HomeWidgetKeys`)

private enum AlrtWidgetConfig {
    static let appGroup = "group.com.safetyalrt.alrt"
    static let payloadKey = "alrt_widget_payload"
    static let kind = "AlrtAlertsWidget"
}

// MARK: - Payload model (decodes the Dart `HomeWidgetPayload` JSON)

private struct WidgetAlert: Codable {
    let band: String
    let severityLabel: String
    let title: String
    let emoji: String
    let area: String?
    let distance: String?
    let time: String?
}

private struct WidgetPayload: Codable {
    let state: String
    let updatedLabel: String
    let deeplink: String
    let activeCount: Int
    let primary: WidgetAlert?
    let more: [WidgetAlert]?

    static func load() -> WidgetPayload? {
        guard
            let defaults = UserDefaults(suiteName: AlrtWidgetConfig.appGroup),
            let raw = defaults.string(forKey: AlrtWidgetConfig.payloadKey),
            let data = raw.data(using: .utf8)
        else { return nil }
        return try? JSONDecoder().decode(WidgetPayload.self, from: data)
    }
}

// MARK: - Timeline

private struct AlrtEntry: TimelineEntry {
    let date: Date
    let payload: WidgetPayload?
}

private struct AlrtProvider: TimelineProvider {
    func placeholder(in context: Context) -> AlrtEntry {
        AlrtEntry(date: Date(), payload: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (AlrtEntry) -> Void) {
        completion(AlrtEntry(date: Date(), payload: WidgetPayload.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AlrtEntry>) -> Void) {
        let entry = AlrtEntry(date: Date(), payload: WidgetPayload.load())
        // The app pushes updates on data change; refresh hourly as a fallback.
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

// MARK: - Colours (locked tokens)

private enum Band {
    static func isCritical(_ b: String) -> Bool { b == "critical" }

    /// Chip fill per band. Critical uses a white pill on the red card.
    static func chipFill(_ b: String) -> Color {
        switch b {
        case "critical": return .white
        case "action": return Color(red: 0xF2/255, green: 0x65/255, blue: 0x22/255)
        default: return Color(red: 0xE9/255, green: 0xB5/255, blue: 0x00/255) // amber
        }
    }

    static func chipText(_ b: String) -> Color {
        switch b {
        case "critical": return Color(red: 0xCC/255, green: 0x10/255, blue: 0x10/255)
        case "action": return .white
        default: return Color(red: 0x1A/255, green: 0x1B/255, blue: 0x1F/255)
        }
    }
}

// The locked solid-red gradient (#FF5247 -> #B80000): CRITICAL only.
private let criticalGradient = LinearGradient(
    colors: [Color(red: 0xFF/255, green: 0x52/255, blue: 0x47/255),
             Color(red: 0xB8/255, green: 0x00/255, blue: 0x00/255)],
    startPoint: .top, endPoint: .bottom
)
private let darkCard = Color(red: 0x16/255, green: 0x17/255, blue: 0x1C/255)
private let successGreen = Color(red: 0x1E/255, green: 0xE2/255, blue: 0x8C/255)

// MARK: - Views

private struct SeverityChip: View {
    let band: String
    let label: String
    var body: some View {
        Text(label.uppercased())
            .font(.system(size: 10, weight: .bold))
            .kerning(0.6)
            .foregroundColor(Band.chipText(band))
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(Capsule().fill(Band.chipFill(band)))
    }
}

private struct AlrtWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: AlrtEntry

    private var isCritical: Bool {
        guard let b = entry.payload?.primary?.band else { return false }
        return Band.isCritical(b)
    }

    var body: some View {
        ZStack {
            (isCritical ? AnyView(criticalGradient) : AnyView(darkCard))
            content
                .padding(14)
        }
        // iOS 17+ container background for the widget.
        .widgetURL(URL(string: entry.payload?.deeplink ?? "alrtwidget://open?screen=alerts"))
    }

    @ViewBuilder
    private var content: some View {
        let payload = entry.payload
        if let primary = payload?.primary, payload?.state == "alert" {
            alertBody(primary: primary, payload: payload!)
        } else {
            allClearBody(updated: payload?.updatedLabel ?? "")
        }
    }

    private func header(_ updated: String) -> some View {
        HStack {
            Text("NEARBY ALERTS")
                .font(.system(size: 10, weight: .bold))
                .kerning(1.2)
                .foregroundColor(isCritical ? Color.white.opacity(0.85) : Color(white: 0.72))
            Spacer()
            Text(updated)
                .font(.system(size: 10))
                .foregroundColor(isCritical ? Color.white.opacity(0.85) : Color(white: 0.55))
        }
    }

    private func alertBody(primary: WidgetAlert, payload: WidgetPayload) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            header(payload.updatedLabel)
            Spacer(minLength: 4)
            // The chip carries the band word and its colour. The emoji
            // that sat beside it drew as a coloured blob from the system
            // font and added nothing the chip does not already say.
            SeverityChip(band: primary.band, label: primary.severityLabel)
            Text(primary.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(2)
            let meta = [primary.area, primary.distance, primary.time]
                .compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: "  ·  ")
            if !meta.isEmpty {
                Text(meta)
                    .font(.system(size: 12))
                    .foregroundColor(isCritical ? Color(white: 1, opacity: 0.9) : Color(white: 0.8))
                    .lineLimit(1)
            }
            if family != .systemSmall {
                let extra = (payload.more?.count ?? 0)
                if extra > 0 {
                    Text(extra == 1 ? "+1 more nearby" : "+\(extra) more nearby")
                        .font(.system(size: 11))
                        .foregroundColor(isCritical ? Color(white: 1, opacity: 0.85) : Color(white: 0.72))
                        .padding(.top, 2)
                }
            }
            Spacer(minLength: 0)
        }
    }

    private func allClearBody(updated: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            header("")
            Spacer(minLength: 4)
            HStack(spacing: 9) {
                ZStack {
                    Circle().fill(successGreen).frame(width: 22, height: 22)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("You\u{2019}re all clear")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text("No warnings near you.")
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.8))
                        .lineLimit(1)
                }
            }
            HStack(spacing: 8) {
                Text("ALL CLEAR")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Color(red: 0.04, green: 0.24, blue: 0.16))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(successGreen))
                Text(updated.replacingOccurrences(of: "Updated", with: "Checked"))
                    .font(.system(size: 11))
                    .foregroundColor(Color(white: 0.55))
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Widget

struct AlrtAlertsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: AlrtWidgetConfig.kind, provider: AlrtProvider()) { entry in
            if #available(iOS 17.0, *) {
                AlrtWidgetView(entry: entry)
                    .containerBackground(for: .widget) { Color.clear }
            } else {
                AlrtWidgetView(entry: entry)
            }
        }
        .configurationDisplayName("Nearby Alerts")
        .description("Live hazard alerts near you.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
