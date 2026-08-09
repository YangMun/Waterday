import Foundation
import UserNotifications

enum ReminderManager {
    private static let idPrefix = "waterday.summary."

    /// Schedules one morning summary per day for the next 7 days, computed
    /// from actual due dates — days with nothing to water get no notification.
    /// Rescheduled on every app open and watering event, so counts stay fresh.
    /// `completion` reports whether notifications are authorized.
    static func reschedule(
        plants: [PlantSnapshot],
        enabled: Bool,
        minutesSinceMidnight: Int,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: (0..<7).map { "\(idPrefix)\($0)" })
        guard enabled else {
            completion(true)
            return
        }

        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: .now)
            for offset in 0..<7 {
                guard let day = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
                // A plant needs water on `day` if its due date is on or before that day.
                let dueCount = plants.filter { calendar.startOfDay(for: $0.nextDue) <= day }.count
                guard dueCount > 0 else { continue }

                var components = calendar.dateComponents([.year, .month, .day], from: day)
                components.hour = minutesSinceMidnight / 60
                components.minute = minutesSinceMidnight % 60
                guard let fireDate = calendar.date(from: components), fireDate > .now else { continue }

                let content = UNMutableNotificationContent()
                content.title = dueCount == 1 ? "1 plant needs water today" : "\(dueCount) plants need water today"
                content.body = "A quick drink keeps them happy."
                content.sound = .default
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                center.add(UNNotificationRequest(identifier: "\(idPrefix)\(offset)", content: content, trigger: trigger))
            }
            DispatchQueue.main.async { completion(true) }
        }
    }
}

/// Value snapshot so scheduling can hop threads without touching SwiftData models.
struct PlantSnapshot {
    let nextDue: Date
}

#if DEBUG
extension ReminderManager {
    /// Fires a one-shot copy of the morning summary a few seconds from now so
    /// the real delivery (lock screen banner) can be captured for screenshots.
    static func scheduleTestShot(after seconds: TimeInterval = 10) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else {
                NSLog("Waterday test reminder: authorization DENIED")
                return
            }
            let content = UNMutableNotificationContent()
            content.title = "3 plants need water today"
            content.body = "A quick drink keeps them happy."
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
            center.add(UNNotificationRequest(identifier: "waterday.test.shot", content: content, trigger: trigger))
        }
    }
}
#endif
