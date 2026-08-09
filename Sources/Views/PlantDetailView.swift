import SwiftUI
import SwiftData

struct PlantDetailView: View {
    let plant: Plant

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var events: [CareEvent]
    @State private var showingEdit = false
    @State private var confirmDelete = false

    init(plant: Plant) {
        self.plant = plant
        let id = plant.id
        _events = Query(
            filter: #Predicate<CareEvent> { $0.plantID == id },
            sort: \CareEvent.date,
            order: .reverse
        )
    }

    var body: some View {
        ZStack {
            DS.bgApp.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    statusCard
                    actions
                    history
                }
                .padding(20)
            }
        }
        .navigationTitle(plant.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Edit") { showingEdit = true }
                    Button("Delete", role: .destructive) { confirmDelete = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            PlantFormView(plant: plant)
        }
        .confirmationDialog("Delete \(plant.name)?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete plant and history", role: .destructive) {
                CareActions.delete(plant, context: modelContext)
                dismiss()
            }
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            PlantThumb(plant: plant, size: 72)
            VStack(alignment: .leading, spacing: 4) {
                Text(plant.name)
                    .font(.title2.bold())
                    .foregroundStyle(DS.textPrimary)
                Text("Every \(plant.intervalDays) days")
                    .font(.subheadline)
                    .foregroundStyle(DS.textMuted)
            }
        }
    }

    private var statusCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                GroundLabel("Next watering")
                if plant.overdueDays > 0 {
                    Text(plant.overdueDays == 1 ? "1 day late" : "\(plant.overdueDays) days late")
                        .font(.title3.bold())
                        .foregroundStyle(DS.terracotta)
                } else if plant.isDueToday {
                    Text("Today")
                        .font(.title3.bold())
                        .foregroundStyle(DS.water)
                } else {
                    Text(plant.nextDue, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                        .font(.title3.bold())
                        .foregroundStyle(DS.textPrimary)
                }
            }
            Spacer()
            Image(systemName: "drop.fill")
                .font(.title)
                .foregroundStyle(plant.overdueDays > 0 ? DS.terracotta : DS.water)
        }
        .cardStyle()
    }

    private var actions: some View {
        HStack(spacing: 10) {
            actionButton("Water", type: .water, fill: DS.water)
            actionButton("Fertilize", type: .fertilize, fill: DS.leaf)
            actionButton("Repot", type: .repot, fill: DS.textMuted)
        }
    }

    private func actionButton(_ label: String, type: CareType, fill: Color) -> some View {
        Button {
            withAnimation(.snappy) {
                CareActions.log(type, for: plant, context: modelContext)
            }
        } label: {
            Label(label, systemImage: type.symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Capsule().fill(fill))
        }
        .buttonStyle(.plain)
    }

    private var history: some View {
        VStack(alignment: .leading, spacing: 12) {
            GroundLabel("History")
            if events.isEmpty {
                Text("No care logged yet.")
                    .font(.subheadline)
                    .foregroundStyle(DS.textMuted)
            } else {
                ForEach(events) { event in
                    HStack(spacing: 12) {
                        Image(systemName: CareType(rawValue: event.type)?.symbol ?? "drop")
                            .foregroundStyle(event.type == CareType.water.rawValue ? DS.water : DS.leaf)
                            .frame(width: 24)
                        Text(CareType(rawValue: event.type)?.label ?? event.type)
                            .font(.subheadline)
                            .foregroundStyle(DS.textPrimary)
                        Spacer()
                        Text(event.date, format: .dateTime.month(.abbreviated).day())
                            .font(.caption)
                            .foregroundStyle(DS.textMuted)
                    }
                    .cardStyle()
                }
            }
        }
    }
}
