import SwiftUI
import SwiftData
import PhotosUI

/// Add (plant == nil) or edit an existing plant.
struct PlantFormView: View {
    let plant: Plant?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var emoji = "🪴"
    @State private var intervalDays = 7
    @State private var lastWatered = Date.now
    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?

    private static let emojiChoices = [
        "🪴", "🌵", "🌿", "🌱", "🌴", "🌳", "🍀", "🌸",
        "🌻", "🌺", "🎋", "🌾", "🍃", "🌷", "🌲", "🪻",
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. Monstera by the window", text: $name)
                }
                Section("Photo or icon") {
                    HStack(spacing: 14) {
                        preview
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            Text(photoData == nil ? "Add photo" : "Change photo")
                        }
                        if photoData != nil {
                            Button("Remove", role: .destructive) {
                                photoData = nil
                                photoItem = nil
                            }
                        }
                    }
                    if photoData == nil {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 8) {
                            ForEach(Self.emojiChoices, id: \.self) { choice in
                                Button {
                                    emoji = choice
                                } label: {
                                    Text(choice)
                                        .font(.title3)
                                        .frame(maxWidth: .infinity, minHeight: 36)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(emoji == choice ? DS.leaf.opacity(0.2) : .clear)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                Section("Watering") {
                    Stepper("Every \(intervalDays) days", value: $intervalDays, in: 1...60)
                    DatePicker("Last watered", selection: $lastWatered, in: ...Date.now, displayedComponents: .date)
                }
            }
            .navigationTitle(plant == nil ? "New Plant" : "Edit Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear(perform: load)
            .onChange(of: photoItem) { _, item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        photoData = downscaled(data)
                    }
                }
            }
        }
    }

    private var preview: some View {
        Group {
            if let photoData, let image = UIImage(data: photoData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(emoji)
                    .font(.title2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(DS.bgApp)
            }
        }
        .frame(width: 52, height: 52)
        .clipShape(Circle())
    }

    private func load() {
        guard let plant else { return }
        name = plant.name
        emoji = plant.emoji
        intervalDays = plant.intervalDays
        lastWatered = plant.lastWatered
        photoData = plant.photoData
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if let plant {
            plant.name = trimmed
            plant.emoji = emoji
            plant.intervalDays = intervalDays
            plant.lastWatered = lastWatered
            plant.photoData = photoData
        } else {
            modelContext.insert(Plant(
                name: trimmed,
                emoji: emoji,
                photoData: photoData,
                intervalDays: intervalDays,
                lastWatered: lastWatered
            ))
        }
        CareActions.didChange(context: modelContext)
        dismiss()
    }

    /// Keeps stored photos reasonable (max ~1000px JPEG) so the store stays small.
    private func downscaled(_ data: Data) -> Data {
        guard let image = UIImage(data: data) else { return data }
        let maxSide: CGFloat = 1000
        let scale = min(1, maxSide / max(image.size.width, image.size.height))
        guard scale < 1 else { return image.jpegData(compressionQuality: 0.8) ?? data }
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
        return resized.jpegData(compressionQuality: 0.8) ?? data
    }
}
