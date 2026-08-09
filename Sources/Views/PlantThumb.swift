import SwiftUI

/// Circular plant thumbnail: the user's photo if set, otherwise its emoji.
struct PlantThumb: View {
    let plant: Plant
    var size: CGFloat = 52

    var body: some View {
        Group {
            if let data = plant.photoData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(plant.emoji)
                    .font(.system(size: size * 0.55))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(DS.bgApp)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(DS.outline, lineWidth: 1))
    }
}
