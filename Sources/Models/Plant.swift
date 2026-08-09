import Foundation
import SwiftData

@Model
final class Plant {
    @Attribute(.unique) var id: UUID
    var name: String
    var emoji: String
    @Attribute(.externalStorage) var photoData: Data?
    var intervalDays: Int
    var lastWatered: Date
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        emoji: String = "🪴",
        photoData: Data? = nil,
        intervalDays: Int = 7,
        lastWatered: Date = .now,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.photoData = photoData
        self.intervalDays = intervalDays
        self.lastWatered = lastWatered
        self.createdAt = createdAt
    }
}

extension Plant {
    var nextDue: Date {
        let start = Calendar.current.startOfDay(for: lastWatered)
        return Calendar.current.date(byAdding: .day, value: intervalDays, to: start) ?? start
    }

    /// Negative = due in the future, 0 = due today, positive = overdue by N days.
    var overdueDays: Int {
        Calendar.current.dateComponents(
            [.day],
            from: nextDue,
            to: Calendar.current.startOfDay(for: .now)
        ).day ?? 0
    }

    var isDueToday: Bool { overdueDays >= 0 }

    /// Days until next watering (0 = today).
    var daysUntilDue: Int { max(0, -overdueDays) }
}

@Model
final class CareEvent {
    var plantID: UUID
    var type: String
    var date: Date

    init(plantID: UUID, type: CareType, date: Date = .now) {
        self.plantID = plantID
        self.type = type.rawValue
        self.date = date
    }
}

enum CareType: String, CaseIterable {
    case water, fertilize, repot

    var label: String {
        switch self {
        case .water: "Watered"
        case .fertilize: "Fertilized"
        case .repot: "Repotted"
        }
    }

    var symbol: String {
        switch self {
        case .water: "drop.fill"
        case .fertilize: "leaf.fill"
        case .repot: "arrow.triangle.2.circlepath"
        }
    }
}
