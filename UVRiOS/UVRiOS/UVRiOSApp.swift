import SwiftUI

@main
struct UVRiOSApp: App {
    @StateObject private var audioProcessor = AudioProcessor()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioProcessor)
        }
    }
}
