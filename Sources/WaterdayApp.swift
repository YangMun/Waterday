import SwiftUI
import SwiftData

@main
struct WaterdayApp: App {
    init() {
        #if DEBUG
        DemoSeed.seedIfRequested(container: AppStore.container)
        if ProcessInfo.processInfo.arguments.contains("-testReminder") {
            ReminderManager.scheduleTestShot()
        }
        #endif
        AdsManager.start()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(AppStore.container)
    }
}
