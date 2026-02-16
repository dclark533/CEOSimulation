import SwiftUI
import CEOSimulationCore

@main
struct CEOSimulationApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowResizability(.contentSize)
        .defaultSize(width: 1200, height: 800)
        #endif
    }
}