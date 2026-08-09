import SwiftUI
import SwiftData

struct PlantsView: View {
    @Query(sort: \Plant.name) private var plants: [Plant]
    @State private var showingForm = false

    var body: some View {
        NavigationStack {
            ZStack {
                DS.bgApp.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Plants")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(DS.textPrimary)
                            Spacer()
                            Button {
                                showingForm = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(width: 36, height: 36)
                                    .background(Circle().fill(ThemeStore.shared.selected.color))
                            }
                            .buttonStyle(.plain)
                        }
                        if plants.isEmpty {
                            VStack(spacing: 10) {
                                Text("🌱")
                                    .font(.system(size: 44))
                                Text("No plants yet")
                                    .font(.headline)
                                    .foregroundStyle(DS.textPrimary)
                                Text("Tap + to add your first plant.")
                                    .font(.subheadline)
                                    .foregroundStyle(DS.textMuted)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else {
                            ForEach(plants) { plant in
                                NavigationLink {
                                    PlantDetailView(plant: plant)
                                } label: {
                                    row(plant)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .bottom) {
                BannerAdView()
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(DS.bgApp)
            }
            .sheet(isPresented: $showingForm) {
                PlantFormView(plant: nil)
            }
        }
    }

    private func row(_ plant: Plant) -> some View {
        HStack(spacing: 14) {
            PlantThumb(plant: plant)
            VStack(alignment: .leading, spacing: 3) {
                Text(plant.name)
                    .font(.headline)
                    .foregroundStyle(DS.textPrimary)
                Text("Every \(plant.intervalDays) days")
                    .font(.caption)
                    .foregroundStyle(DS.textMuted)
            }
            Spacer()
            if plant.isDueToday {
                Image(systemName: "drop.fill")
                    .foregroundStyle(plant.overdueDays > 0 ? DS.terracotta : DS.water)
            } else {
                Text(plant.daysUntilDue == 1 ? "1d" : "\(plant.daysUntilDue)d")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DS.textMuted)
            }
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(DS.textMuted)
        }
        .cardStyle()
    }
}
