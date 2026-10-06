import SwiftUI
import WatchKit

/// SOS from the wrist: who it goes to first (from the backend's own
/// preview), then a deliberate 3-second hold, then the server's answer.
/// Never a one-tap SOS, never a location, never an emergency-service call.
struct SosScreen: View {
  let row: CircleRow
  @EnvironmentObject private var store: WatchStore
  @State private var preview: WatchStore.SosPreview?
  @State private var loading = true
  @State private var sending = false

  var body: some View {
    ScrollView {
      VStack(spacing: 10) {
        Text("SOS to \(row.name)").font(.headline).multilineTextAlignment(.center)
        if loading {
          ProgressView()
        } else if let preview {
          Text(preview.detail).font(.footnote).multilineTextAlignment(.center)
          if preview.canSend {
            HoldToSendButton { sending = true }
            Text("Hold for 3 seconds").font(.footnote).foregroundStyle(.secondary)
          }
        } else {
          Text("Your iPhone isn't connected. Use ALRT on your iPhone to send an SOS.")
            .font(.footnote).multilineTextAlignment(.center)
        }
        Text("In immediate danger, call your local emergency number.")
          .font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
      }
    }
    .navigationTitle("SOS")
    .navigationDestination(isPresented: $sending) {
      ActionScreen(kind: .sos, row: row)
    }
    .task {
      preview = await store.sosPreview(row)
      loading = false
    }
  }
}

/// Press and hold for 3 seconds; a ring fills while held and resets if
/// released early. Haptic ticks while holding, so it is felt, not just seen.
struct HoldToSendButton: View {
  let onComplete: () -> Void
  private let duration: Double = 3
  @State private var progress: Double = 0
  @State private var holding = false
  @State private var timer: Timer?

  var body: some View {
    ZStack {
      Circle().fill(AlrtColors.sosRed)
      Circle()
        .trim(from: 0, to: progress)
        .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
        .rotationEffect(.degrees(-90))
        .padding(4)
      Text(holding ? "Keep holding" : "Hold\nfor SOS")
        .font(.headline).foregroundStyle(.white).multilineTextAlignment(.center)
    }
    .frame(width: 110, height: 110)
    .contentShape(Circle())
    .onLongPressGesture(minimumDuration: duration, maximumDistance: 30, perform: {
      stop()
      progress = 1
      WKInterfaceDevice.current().play(.notification)
      onComplete()
    }, onPressingChanged: { pressing in
      if pressing { begin() } else { stop() }
    })
    .accessibilityLabel("Hold for 3 seconds to send SOS")
    .accessibilityAddTraits(.isButton)
  }

  private func begin() {
    holding = true
    progress = 0
    let start = Date()
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
      DispatchQueue.main.async {
        let elapsed = Date().timeIntervalSince(start)
        progress = min(elapsed / duration, 1)
        // One tick each second while held, so the hold is felt.
        if Int(elapsed * 20) % 20 == 0 { WKInterfaceDevice.current().play(.click) }
      }
    }
  }

  private func stop() {
    holding = false
    timer?.invalidate()
    timer = nil
    if progress < 1 { withAnimation { progress = 0 } }
  }
}
