import Foundation
import SwiftData
import WidgetKit

#if DEBUG
/// Seeds sample plants when launched with "-seedDemoData" so due/overdue
/// states, history, and widgets can be exercised in the simulator.
enum DemoSeed {
    static func seedIfRequested(container: ModelContainer) {
        guard ProcessInfo.processInfo.arguments.contains("-seedDemoData") else { return }
        let context = ModelContext(container)
        let existing = (try? context.fetch(FetchDescriptor<Plant>())) ?? []
        guard existing.isEmpty else { return }

        let calendar = Calendar.current
        func daysAgo(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: -days, to: .now) ?? .now
        }

        let samples: [(String, String, Int, Int)] = [
            // (name, emoji, intervalDays, lastWateredDaysAgo)
            ("Monstera", "🪴", 7, 7),      // due today
            ("Cactus Club", "🌵", 21, 23), // overdue 2 days
            ("Basil", "🌿", 3, 3),         // due today
            ("Rubber Tree", "🌳", 10, 4),  // due in 6 days
            ("Sunny", "🌻", 5, 2),         // due in 3 days
        ]
        for (name, emoji, interval, ago) in samples {
            let plant = Plant(name: name, emoji: emoji, intervalDays: interval, lastWatered: daysAgo(ago))
            context.insert(plant)
            // A little care history for the detail screen.
            context.insert(CareEvent(plantID: plant.id, type: .water, date: daysAgo(ago)))
            context.insert(CareEvent(plantID: plant.id, type: .water, date: daysAgo(ago + interval)))
            if interval > 5 {
                context.insert(CareEvent(plantID: plant.id, type: .fertilize, date: daysAgo(ago + 3)))
            }
        }
        try? context.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
#endif
