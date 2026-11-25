import SwiftUI
import FirebaseCore

@main
struct Lab14IntroFirebaseApp: App {

    // Configura Firebase cuando inicia la app
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
