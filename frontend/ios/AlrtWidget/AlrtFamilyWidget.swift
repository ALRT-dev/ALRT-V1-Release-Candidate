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
/// Family identity: the same deep-indigo -> bright-purple gradient as
/// FamilyColors.headerGradient in the app.
private let familyPurpleGradient = LinearGradient(
    colors: [Color(red: 0x7A/255, green: 0x4B/255, blue: 0xF5/255),
             Color(red: 0x52/255, green: 0x38/255, blue: 0xDE/255),
             Color(red: 0x1B/255, green: 0x14/255, blue: 0x70/255)],
    startPoint: .topLeading, endPoint: .bottomTrailing
)
/// "Everyone's safe": the same bright green -> teal gradient as the in-app
/// I'm Safe action, not just coloured text on the identity card.
private let familySafeGradient = LinearGradient(
    colors: [Color(red: 0x05/255, green: 0x96/255, blue: 0x69/255),
             Color(red: 0x2D/255, green: 0xD4/255, blue: 0xA7/255)],
    startPoint: .topLeading, endPoint: .bottomTrailing
)
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
            background
            VStack(alignment: .leading, spacing: 4) {
                Text((entry.payload?.circleName ?? "Family").uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .kerning(1.2)
                    .foregroundColor(kickerColor)
                    .lineLimit(1)
                Spacer(minLength: 4)
                Text(entry.payload?.headline ?? "No family circle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(headlineColor)
                    .lineLimit(2)
                Text(entry.payload?.sub ?? "Set up in the app")
                    .font(.system(size: 12))
                    .foregroundColor(subColor)
                    .lineLimit(2)
                groupRow
                Spacer(minLength: 0)
            }
            .padding(14)
        }
        .widgetURL(URL(string: entry.payload?.deeplink ?? "alrtwidget://open?screen=family"))
    }

    /// The critical red gradient stays locked to a live SOS (rule 6); a
    /// safe circle gets the same green -> teal identity as the in-app I'm
    /// Safe action; everything else carries the Family purple identity.
    @ViewBuilder private var background: some View {
        if isCritical {
            familyCriticalGradient
        } else if isSafe {
            familySafeGradient
        } else {
            familyPurpleGradient
        }
    }

    private var kickerColor: Color {
        if isCritical { return Color.white.opacity(0.85) }
        if isSafe { return Color(red: 0xDF/255, green: 0xFD/255, blue: 0xF2/255) }
        return Color(red: 0xD9/255, green: 0xD0/255, blue: 0xF7/255)
    }

    private var subColor: Color {
        if isCritical { return Color(white: 1, opacity: 0.9) }
        if isSafe { return Color(red: 0xE3/255, green: 0xFB/255, blue: 0xF2/255) }
        return Color(red: 0xCF/255, green: 0xC7/255, blue: 0xEC/255)
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
        // Safe and critical both carry their colour on the background now,
        // so the headline stays white on either; only an unanswered
        // check-in still needs its own amber to stand out on purple.
        if !isCritical && !isSafe && isCheckInRequested { return familyRequestAmber }
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
