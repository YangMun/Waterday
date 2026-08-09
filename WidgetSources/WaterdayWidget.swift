import WidgetKit
import SwiftUI
import SwiftData

struct WaterdayTimelineEntry: TimelineEntry {
    let date: Date
    let dueNames: [String]
    let dueEmojis: [String]

    var dueCount: Int { dueNames.count }

    static let placeholder = WaterdayTimelineEntry(
        date: .now,
        dueNames: ["Monstera", "Basil"],
        dueEmojis: ["🪴", "🌿"]
    )
}

struct WaterdayProvider: TimelineProvider {
    func placeholder(in context: Context) -> WaterdayTimelineEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (WaterdayTimelineEntry) -> Void) {
        completion(context.isPreview ? .placeholder : makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WaterdayTimelineEntry>) -> Void) {
        let entry = makeEntry()
        let midnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now)
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }

    private func makeEntry() -> WaterdayTimelineEntry {
        guard let plants = loadPlants() else {
            return WaterdayTimelineEntry(date: .now, dueNames: [], dueEmojis: [])
        }
        let due = plants.filter(\.isDueToday).sorted { $0.overdueDays > $1.overdueDays }
        return WaterdayTimelineEntry(
            date: .now,
            dueNames: due.map(\.name),
            dueEmojis: due.map(\.emoji)
        )
    }
}

/// File-scope so `Plant` resolves to the SwiftData model, not a provider associated type.
private func loadPlants() -> [Plant]? {
    try? ModelContext(AppStore.container).fetch(FetchDescriptor<Plant>())
}

struct WaterdayWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WaterdayTimelineEntry

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:
                circular
            case .accessoryInline:
                inline
            case .accessoryRectangular:
                rectangular
            default:
                home
            }
        }
        .containerBackground(for: .widget) {
            family.isAccessory ? Color.clear : DS.bgElevated
        }
    }

    private var home: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundStyle(DS.water)
                Text(entry.dueCount == 0 ? "All happy" : "\(entry.dueCount) to water")
                    .font(.headline)
                    .foregroundStyle(DS.textPrimary)
                Spacer()
            }
            if entry.dueCount == 0 {
                Text("Nothing needs water today 🌿")
                    .font(.caption)
                    .foregroundStyle(DS.textMuted)
            } else {
                ForEach(Array(zip(entry.dueNames, entry.dueEmojis).prefix(family == .systemMedium ? 3 : 2)), id: \.0) { name, emoji in
                    HStack(spacing: 6) {
                        Text(emoji)
                            .font(.caption)
                        Text(name)
                            .font(.caption)
                            .foregroundStyle(DS.textPrimary)
                            .lineLimit(1)
                    }
                }
                if entry.dueCount > (family == .systemMedium ? 3 : 2) {
                    Text("+\(entry.dueCount - (family == .systemMedium ? 3 : 2)) more")
                        .font(.caption2)
                        .foregroundStyle(DS.textMuted)
                }
            }
            Spacer(minLength: 0)
        }
    }

    private var circular: some View {
        VStack(spacing: 2) {
            Image(systemName: entry.dueCount == 0 ? "leaf.fill" : "drop.fill")
                .font(.headline)
            if entry.dueCount > 0 {
                Text("\(entry.dueCount)")
                    .font(.caption.bold())
            }
        }
    }

    private var inline: some View {
        Text(entry.dueCount == 0 ? "Plants are happy" : "\(entry.dueCount) plants need water")
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Waterday")
                .font(.caption.bold())
            Text(entry.dueCount == 0 ? "Nothing to water today" : entry.dueNames.prefix(2).joined(separator: ", "))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension WidgetFamily {
    var isAccessory: Bool {
        switch self {
        case .accessoryCircular, .accessoryInline, .accessoryRectangular: true
        default: false
        }
    }
}

@main
struct WaterdayWidgetBundle: WidgetBundle {
    var body: some Widget {
        WaterdayWidget()
    }
}

struct WaterdayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WaterdayWidget", provider: WaterdayProvider()) { entry in
            WaterdayWidgetView(entry: entry)
        }
        .configurationDisplayName("Waterday")
        .description("Which plants need water today.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}
