import SwiftUI
import WatchKit

// MARK: - Home: every circle, most urgent first

struct RootView: View {
  @EnvironmentObject private var store: WatchStore

  var body: some View {
    NavigationStack(path: $store.path) {
      content
        .navigationTitle("ALRT")
        .navigationDestination(for: String.self) { circleId in
          if let row = store.row(circleId) {
            CircleScreen(row: row)
          } else {
            MessageView(symbol: "person.3", title: "Circle not found", detail: "Open ALRT on your iPhone.")
          }
        }
    }
    .tint(AlrtColors.indigo)
  }

  @ViewBuilder private var content: some View {
    if let status = store.status {
      if !status.signedIn {
        MessageView(symbol: "iphone", title: "Sign in on your iPhone", detail: "Open ALRT on your iPhone and sign in. Your circles will appear here.")
      } else if status.rows.isEmpty {
        MessageView(symbol: "person.3", title: status.headline, detail: status.sub)
      } else {
        List {
          ForEach(status.rows) { row in
            NavigationLink(value: row.id) { CircleRowView(row: row) }
              .listItemTint(row.isSos ? AlrtColors.sosRed.opacity(0.35) : nil)
          }
          if status.moreCircles > 0 {
            Text("+\(status.moreCircles) more on your iPhone")
              .font(.footnote).foregroundStyle(.secondary)
          }
          FreshnessFooter(generatedAt: status.generatedAt, reachable: store.phoneReachable)
        }
      }
    } else {
      MessageView(symbol: "iphone.radiowaves.left.and.right", title: "Open ALRT on your iPhone", detail: "Your circles appear here once your iPhone has connected.")
    }
  }
}

struct CircleRowView: View {
  let row: CircleRow

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(row.name).font(.headline).lineLimit(1)
      HStack(spacing: 6) {
        Circle().fill(row.tint).frame(width: 8, height: 8)
        Text(row.headline).font(.footnote).lineLimit(2)
      }
    }
    .padding(.vertical, 4)
    .accessibilityElement(children: .combine)
  }
}

/// Honest freshness: when the iPhone last told us, and whether it is near.
struct FreshnessFooter: View {
  let generatedAt: Date?
  let reachable: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      if let generatedAt {
        Text("Updated \(generatedAt.formatted(date: .omitted, time: .shortened))")
      }
      if !reachable {
        Text("iPhone not connected").foregroundStyle(AlrtColors.actionOrange)
      }
    }
    .font(.footnote)
    .foregroundStyle(.secondary)
    .listRowBackground(Color.clear)
  }
}

// MARK: - One circle: check in, or SOS

struct CircleScreen: View {
  let row: CircleRow

  var body: some View {
    ScrollView {
      VStack(spacing: 12) {
        VStack(spacing: 2) {
          Text(row.headline).font(.headline).multilineTextAlignment(.center)
          if !row.sub.isEmpty {
            Text(row.sub).font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
          }
        }

        switch row.kind {
        case .sosMine:
          Text("Your SOS is active. To end it, use ALRT on your iPhone.")
            .font(.footnote).multilineTextAlignment(.center)
        case .sosOther:
          Text("Open ALRT on your iPhone to see who and respond.")
            .font(.footnote).multilineTextAlignment(.center)
          CheckInButton(row: row)
        default:
          CheckInButton(row: row)
          NavigationLink {
            SosScreen(row: row)
          } label: {
            Label("SOS", systemImage: "sos")
              .frame(maxWidth: .infinity)
          }
          .tint(AlrtColors.sosRed)
        }
      }
      .padding(.horizontal, 4)
    }
    .navigationTitle(row.name)
  }
}

struct CheckInButton: View {
  let row: CircleRow

  var body: some View {
    NavigationLink {
      ActionScreen(kind: .checkIn, row: row)
    } label: {
      VStack(spacing: 2) {
        Image(systemName: "checkmark.circle.fill").font(.title3)
        Text("Check in to \(row.name)").font(.headline).multilineTextAlignment(.center)
      }
      .frame(maxWidth: .infinity, minHeight: 64)
    }
    .buttonStyle(.borderedProminent)
    .tint(AlrtColors.checkInGreen)
    .accessibilityHint("Sends a check-in to \(row.name). No location is sent.")
  }
}

// MARK: - Sending, then the server's answer

struct ActionScreen: View {
  enum Kind { case checkIn, sos }

  let kind: Kind
  let row: CircleRow
  @EnvironmentObject private var store: WatchStore
  @Environment(\.dismiss) private var dismiss
  @State private var outcome: ActionOutcome?
  /// One key per tap: "Try again" after an uncertain answer reuses it, so
  /// the server returns the first result instead of acting twice.
  @State private var key = UUID().uuidString

  var body: some View {
    Group {
      switch outcome {
      case nil:
        VStack(spacing: 8) {
          ProgressView()
          Text("Sending…").font(.headline)
        }
      case .done(let title, let detail)?:
        ResultView(symbol: "checkmark.circle.fill", tint: kind == .sos ? AlrtColors.sosRed : AlrtColors.checkInGreen, title: title, detail: detail) {
          Button("Done") { dismiss() }
        }
      case .notSent(let title, let detail)?:
        ResultView(symbol: "xmark.circle.fill", tint: AlrtColors.actionOrange, title: title, detail: detail) {
          Button("Try again") { Task { await send() } }
        }
      case .uncertain?:
        ResultView(symbol: "questionmark.circle.fill", tint: AlrtColors.monitorYellow, title: "Not confirmed", detail: "We couldn't confirm it was sent. Check ALRT on your iPhone, or try again. Trying again never sends it twice.") {
          Button("Try again") { Task { await send() } }
        }
      }
    }
    .navigationBarBackButtonHidden(outcome == nil)
    .task { if outcome == nil { await send() } }
  }

  private func send() async {
    outcome = nil
    let result: ActionOutcome
    switch kind {
    case .checkIn: result = await store.checkIn(row, key: key)
    case .sos: result = await store.sendSos(row, key: key)
    }
    outcome = result
    switch result {
    case .done: WKInterfaceDevice.current().play(.success)
    case .notSent, .uncertain: WKInterfaceDevice.current().play(.failure)
    }
  }
}

struct ResultView<Actions: View>: View {
  let symbol: String
  let tint: Color
  let title: String
  let detail: String
  @ViewBuilder let actions: () -> Actions

  var body: some View {
    ScrollView {
      VStack(spacing: 8) {
        Image(systemName: symbol).font(.system(size: 36)).foregroundStyle(tint)
        Text(title).font(.headline).multilineTextAlignment(.center)
        if !detail.isEmpty {
          Text(detail).font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        actions()
      }
    }
  }
}

struct MessageView: View {
  let symbol: String
  let title: String
  let detail: String

  var body: some View {
    ScrollView {
      VStack(spacing: 8) {
        Image(systemName: symbol).font(.title2).foregroundStyle(AlrtColors.indigo)
        Text(title).font(.headline).multilineTextAlignment(.center)
        Text(detail).font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
      }
      .padding(.top, 8)
    }
  }
}
