import WidgetKit
import SwiftUI

private enum FamilyWidgetConfig {
    // Flavour-specific: the TEST app (any bundle id containing ".dev") uses
    // the separate group.com.safetyalrt.alrt.dev, so a TEST install never
    // shares widget data with the live app. Matches Runner-dev.entitlements
    // and HomeWidgetKeys.appGroupId on the Dart side.
    static var appGroup: String {
        (Bundle.main.bundleIdentifier ?? "").contains(".dev")
            ? "group.com.safetyalrt.alrt.dev"
            : "group.com.safetyalrt.alrt"
    }
    static let payloadKey = "alrt_family_widget_payload"
    static let kind = "AlrtFamilyWidget"
}

/// One family group as the widget draws it. The extension cannot fetch a
/// URL, so the app renders each icon to a PNG in the App Group container
/// and passes the path.
private struct FamilyGroup: Codable {
    let circleId: String
    let name: String
    let isCurrent: Bool
    let iconPath: String?
}

private struct FamilyPayload: Codable {
    let state: String
    let headline: String
    let sub: String
    let deeplink: String
    let circleName: String?
    let isCritical: Bool
    let groups: [FamilyGroup]?

    static func load() -> FamilyPayload? {
        guard
            let defaults = UserDefaults(suiteName: FamilyWidgetConfig.appGroup),
            let raw = defaults.string(forKey: FamilyWidgetConfig.payloadKey),
            let data = raw.data(using: .utf8)
        else { return nil }
        return try? JSONDecoder().decode(FamilyPayload.self, from: data)
    }
}

private struct FamilyEntry: TimelineEntry {
    let date: Date
    let payload: FamilyPayload?
}

private struct FamilyProvider: TimelineProvider {
    func placeholder(in context: Context) -> FamilyEntry {
        FamilyEntry(date: Date(), payload: nil)
    }
    func getSnapshot(in context: Context, completion: @escaping (FamilyEntry) -> Void) {
        completion(FamilyEntry(date: Date(), payload: FamilyPayload.load()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<FamilyEntry>) -> Void) {
        let entry = FamilyEntry(date: Date(), payload: FamilyPayload.load())
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

private let familyCriticalGradient = LinearGradient(
    colors: [Color(red: 0xFF/255, green: 0x52/255, blue: 0x47/255),
             Color(red: 0xB8/255, green: 0x00/255, blue: 0x00/255)],
    startPoint: .top, endPoint: .bottom
)
private let familyDarkCard = Color(red: 0x16/255, green: 0x17/255, blue: 0x1C/255)
private let familySuccessGreen = Color(red: 0x1E/255, green: 0xE2/255, blue: 0x8C/255)
/// The Monitor band amber, for a check-in the user still owes an answer to.
private let familyRequestAmber = Color(red: 0xF5/255, green: 0xC5/255, blue: 0x18/255)

private struct FamilyWidgetView: View {
    let entry: FamilyEntry

    private var isCritical: Bool { entry.payload?.isCritical ?? false }
    private var isSafe: Bool { entry.payload?.state == "safe" }
    private var isCheckInRequested: Bool {
        entry.payload?.state == "check_in_requested"
    }

    var body: some View {
        ZStack {
            (isCritical ? AnyView(familyCriticalGradient) : AnyView(familyDarkCard))
            VStack(alignment: .leading, spacing: 4) {
                Text((entry.payload?.circleName ?? "Family").uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .kerning(1.2)
                    .foregroundColor(isCritical ? Color.white.opacity(0.85) : Color(white: 0.72))
                    .lineLimit(1)
                Spacer(minLength: 4)
                Text(entry.payload?.headline ?? "No family circle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(headlineColor)
                    .lineLimit(2)
                Text(entry.payload?.sub ?? "Set up in the app")
                    .font(.system(size: 12))
                    .foregroundColor(isCritical ? Color(white: 1, opacity: 0.9) : Color(white: 0.8))
                    .lineLimit(2)
                groupRow
                Spacer(minLength: 0)
            }
            .padding(14)
        }
        .widgetURL(URL(string: entry.payload?.deeplink ?? "alrtwidget://open?screen=family"))
    }

    /// One icon per group the user is in, so every group is visible from
    /// the home screen and not only the one the headline reports on. A
    /// single group adds nothing the kicker does not already say, so the
    /// row starts at two.
    @ViewBuilder private var groupRow: some View {
        let groups = entry.payload?.groups ?? []
        if groups.count > 1 {
            HStack(spacing: 6) {
                ForEach(groups.prefix(4), id: \.circleId) { group in
                    if let path = group.iconPath,
                       let image = UIImage(contentsOfFile: path) {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                            // The group the headline is about is drawn at
                            // full strength; the others sit back.
                            .opacity(group.isCurrent ? 1 : 0.55)
                    }
                }
            }
            .padding(.top, 8)
        }
    }

    private var headlineColor: Color {
        if isCritical { return .white }
        if isSafe { return familySuccessGreen }
        if isCheckInRequested { return familyRequestAmber }
        return .white
    }
}

struct AlrtFamilyWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: FamilyWidgetConfig.kind, provider: FamilyProvider()) { entry in
            if #available(iOS 17.0, *) {
                FamilyWidgetView(entry: entry)
                    .containerBackground(for: .widget) { Color.clear }
            } else {
                FamilyWidgetView(entry: entry)
            }
        }
        .configurationDisplayName("Family status")
        .description("Your family circle at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
