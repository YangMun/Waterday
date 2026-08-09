import Foundation
import SwiftData

enum AppGroup {
    static let id = "group.com.yangmunkyeong.waterday"

    static var containerURL: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id)
            ?? URL.applicationSupportDirectory
    }
}

enum AppStore {
    static let container: ModelContainer = {
        let storeURL = AppGroup.containerURL.appendingPathComponent("Waterday.store")
        let config = ModelConfiguration(url: storeURL)
        do {
            return try ModelContainer(for: Plant.self, CareEvent.self, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
}
