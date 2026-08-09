import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Plant.name) private var plants: [Plant]
    @State private var themeStore = ThemeStore.shared

    private var duePlants: [Plant] {
        plants.filter(\.isDueToday).sorted { $0.overdueDays > $1.overdueDays }
    }

    private var upcoming: [Plant] {
        plants.filter { !$0.isDueToday }.sorted { $0.daysUntilDue < $1.daysUntilDue }.prefix(3).map { $0 }
    }

    var body: some View {
        ZStack {
            DS.bgApp.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    if plants.isEmpty {
                        emptyGarden
                    } else if duePlants.isEmpty {
                        allHappy
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            GroundLabel("Needs water")
                            ForEach(duePlants) { plant in
                                dueCard(plant)
                            }
                        }
                    }
                    if !upcoming.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            GroundLabel("Coming up")
                            ForEach(upcoming) { plant in
                                upcomingRow(plant)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Today")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(DS.textPrimary)
            Text(Date.now, format: .dateTime.weekday(.wide).month(.wide).day())
                .font(.subheadline)
                .foregroundStyle(DS.textMuted)
        }
    }

    private var emptyGarden: some View {
        VStack(spacing: 10) {
            Text("🪴")
                .font(.system(size: 44))
            Text("Add your first plant")
                .font(.headline)
                .foregroundStyle(DS.textPrimary)
            Text("Head to the Plants tab and tap +")
                .font(.subheadline)
                .foregroundStyle(DS.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private var allHappy: some View {
        VStack(spacing: 10) {
            Text("🌿")
                .font(.system(size: 44))
            Text("All plants are happy")
                .font(.headline)
                .foregroundStyle(DS.textPrimary)
            Text("Nothing needs water today.")
                .font(.subheadline)
                .foregroundStyle(DS.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func dueCard(_ plant: Plant) -> some View {
        HStack(spacing: 14) {
            PlantThumb(plant: plant)
            VStack(alignment: .leading, spacing: 3) {
                Text(plant.name)
                    .font(.headline)
                    .foregroundStyle(DS.textPrimary)
                if plant.overdueDays > 0 {
                    Text(plant.overdueDays == 1 ? "1 day late" : "\(plant.overdueDays) days late")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DS.terracotta)
                } else {
                    Text("Due today")
                        .font(.caption)
                        .foregroundStyle(DS.textMuted)
                }
            }
            Spacer()
            Button {
                withAnimation(.snappy) {
                    CareActions.water(plant, context: modelContext)
                }
            } label: {
                Image(systemName: "drop.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(DS.water))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Mark \(plant.name) as watered")
        }
        .cardStyle()
    }

    private func upcomingRow(_ plant: Plant) -> some View {
        HStack(spacing: 14) {
            PlantThumb(plant: plant, size: 40)
            Text(plant.name)
                .font(.subheadline)
                .foregroundStyle(DS.textPrimary)
            Spacer()
            Text(plant.daysUntilDue == 1 ? "tomorrow" : "in \(plant.daysUntilDue) days")
                .font(.caption)
                .foregroundStyle(DS.textMuted)
        }
        .cardStyle()
    }
}
