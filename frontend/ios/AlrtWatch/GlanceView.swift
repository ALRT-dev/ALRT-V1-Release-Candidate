import SwiftUI

struct GlanceView: View {
    @EnvironmentObject var model: GlanceModel

    private func color(for band: String) -> Color {
        switch band {
        case "critical": return Color(red: 0.855, green: 0.122, blue: 0.176)
        case "action": return Color(red: 0.941, green: 0.494, blue: 0.106)
        case "monitor": return Color(red: 0.961, green: 0.773, blue: 0.094)
        default: return Color(red: 0.541, green: 0.576, blue: 0.627)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                if !model.hasData {
                    Text("ALRT").font(.headline).foregroundColor(.orange)
                    Text("Open ALRT on your iPhone to see nearby alerts here.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                } else if let alert = model.glance?.primary, model.glance?.state != "all_clear" {
                    // Severity is always a word as well as a colour.
                    Text(alert.severityLabel)
                        .font(.headline)
                        .foregroundColor(color(for: alert.band))
                    Text(alert.title).font(.body).bold().multilineTextAlignment(.center)
                    let place = [alert.area, alert.distance].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " · ")
                    if !place.isEmpty { Text(place).font(.footnote) }
                    if let time = alert.time, !time.isEmpty {
                        Text(time).font(.caption2).foregroundColor(.secondary)
                    }
                    if let count = model.glance?.activeCount, count > 1 {
                        Text("+\(count - 1) more on your iPhone").font(.caption2).foregroundColor(.secondary)
                    }
                } else {
                    Text("All clear").font(.headline).foregroundColor(.green)
                    Text("No active alerts near you.").font(.footnote)
                }
                if let updated = model.glance?.updatedLabel, !updated.isEmpty {
                    Text(updated).font(.caption2).foregroundColor(.secondary)
                }
                Text("If you are experiencing an emergency, call your local emergency number.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 6)
        }
    }
}
