import SwiftUI

@main
struct AlrtWatchApp: App {
    @StateObject private var model = GlanceModel.shared

    var body: some Scene {
        WindowGroup {
            GlanceView().environmentObject(model)
        }
    }
}
