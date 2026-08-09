import SwiftUI
import UIKit

/// "Greenhouse" design system — warm cream glasshouse ground in light,
/// deep moss night in dark. Leaf green is the working accent, water blue is
/// reserved for watering actions, terracotta only ever means "overdue".
enum DS {
    // Ground (adaptive)
    static let bgApp = Color(light: 0xF3F0E5, dark: 0x12170F)
    static let bgElevated = Color(light: 0xFCFAF2, dark: 0x1C231A)
    static let outline = Color(light: 0xDFD9C7, dark: 0x333B2E)

    // Text (adaptive)
    static let textPrimary = Color(light: 0x22301F, dark: 0xEDF0E4)
    static let textMuted = Color(light: 0x83887A, dark: 0x969C8B)

    // Roles
    static let leaf = Color(light: 0x4E7A54, dark: 0x7FA886)
    static let water = Color(light: 0x4F84AC, dark: 0x7FABCB)
    static let terracotta = Color(light: 0xC0603F, dark: 0xD07A5B)

    /// Hairline around cards — subtle on light, near-invisible on dark.
    static let cardStroke = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? .clear : UIColor(hex: 0xE5DFCD)
    })

    static let cardRadius: CGFloat = 22
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(uiColor: UIColor(hex: hex))
    }

    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

extension View {
    func cardStyle() -> some View {
        self
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DS.bgElevated, in: RoundedRectangle(cornerRadius: DS.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DS.cardRadius, style: .continuous)
                    .stroke(DS.cardStroke, lineWidth: 1)
            )
    }
}

/// Pill chip row (selected = leaf-tinted fill, unselected = outlined ground).
struct ChipPicker<T: Hashable>: View {
    let options: [(T, String)]
    @Binding var selection: T

    var body: some View {
        HStack(spacing: 10) {
            ForEach(options, id: \.0) { value, label in
                Button {
                    selection = value
                } label: {
                    Text(label)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(selection == value ? Color.white : DS.textMuted)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            Capsule().fill(selection == value ? DS.leaf : DS.bgElevated)
                        )
                        .overlay(
                            Capsule().stroke(selection == value ? .clear : DS.outline, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// Section label on the ground — small caps with tracking.
struct GroundLabel: View {
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text.uppercased())
            .font(.caption.weight(.semibold))
            .tracking(1.2)
            .foregroundStyle(DS.textMuted)
    }
}
