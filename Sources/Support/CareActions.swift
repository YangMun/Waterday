import Foundation
import SwiftData
import WidgetKit

/// Single funnel for every data mutation so widgets and notification
/// schedules never drift out of sync with the store.
enum CareActions {
    static func water(_ plant: Plant, context: ModelContext) {
        plant.lastWatered = .now
        context.insert(CareEvent(plantID: plant.id, type: .water))
        didChange(context: context)
    }

    static func log(_ type: CareType, for plant: Plant, context: ModelContext) {
        if type == .water {
            water(plant, context: context)
        } else {
            context.insert(CareEvent(plantID: plant.id, type: type))
            didChange(context: context)
        }
    }

    static func delete(_ plant: Plant, context: ModelContext) {
        let id = plant.id
        try? context.delete(model: CareEvent.self, where: #Predicate { $0.plantID == id })
        context.delete(plant)
        didChange(context: context)
    }

    static func didChange(context: ModelContext) {
        WidgetCenter.shared.reloadAllTimelines()
        rescheduleReminders(context: context)
    }

    static func rescheduleReminders(context: ModelContext, completion: @escaping (Bool) -> Void = { _ in }) {
        let defaults = UserDefaults.standard
        let enabled = defaults.bool(forKey: "reminderEnabled")
        let minutes = defaults.object(forKey: "reminderMinutes") as? Int ?? 9 * 60
        let plants = (try? context.fetch(FetchDescriptor<Plant>())) ?? []
        ReminderManager.reschedule(
            plants: plants.map { PlantSnapshot(nextDue: $0.nextDue) },
            enabled: enabled,
            minutesSinceMidnight: minutes,
            completion: completion
        )
    }
}
