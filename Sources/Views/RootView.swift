import SwiftUI
import SwiftData

struct RootView: View {
    enum Tab: String {
        case today, plants, settings
    }

    @State private var selection: Tab = {
        #if DEBUG
        if let index = ProcessInfo.processInfo.arguments.firstIndex(of: "-initialTab"),
           let tab = Tab(rawValue: ProcessInfo.processInfo.arguments[safe: index + 1] ?? "") {
            return tab
        }
        #endif
        return .today
    }()

    @AppStorage("appearance") private var appearance = "system"
    @State private var themeStore = ThemeStore.shared
    @Environment(\.modelContext) private var modelContext

    private var colorScheme: ColorScheme? {
        switch appearance {
        case "dark": .dark
        case "light": .light
        default: nil
        }
    }

    var body: some View {
        TabView(selection: $selection) {
            TodayView()
                .tabItem { Label("Today", systemImage: "drop") }
                .tag(Tab.today)
            PlantsView()
                .tabItem { Label("Plants", systemImage: "leaf") }
                .tag(Tab.plants)
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
        .tint(themeStore.selected.color)
        .preferredColorScheme(colorScheme)
        .onAppear {
            AdsManager.requestTrackingAuthorization()
            RewardedAdController.shared.preload()
            // Widgets and the notification schedule both depend on due dates,
            // which shift at midnight — refresh them on every foreground.
            CareActions.didChange(context: modelContext)
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
