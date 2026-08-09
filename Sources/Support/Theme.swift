import SwiftUI

/// Themes are pot glazes: the accent color of buttons, chips, and highlights.
enum AppTheme: String, CaseIterable, Identifiable {
    case leaf, terracotta, ocean, lavender

    var id: String { rawValue }

    var name: String {
        switch self {
        case .leaf: "Leaf"
        case .terracotta: "Clay"
        case .ocean: "Ocean"
        case .lavender: "Lilac"
        }
    }

    var color: Color {
        switch self {
        case .leaf: DS.leaf
        case .terracotta: Color(light: 0xB96A48, dark: 0xCE8262)
        case .ocean: Color(light: 0x4F84AC, dark: 0x7FABCB)
        case .lavender: Color(light: 0x8A7BB0, dark: 0xA79BC9)
        }
    }

    /// The default theme ships unlocked; the rest are unlocked by watching a rewarded ad.
    var isFree: Bool { self == .leaf }
}

@Observable
final class ThemeStore {
    static let shared = ThemeStore()

    private let selectedKey = "selectedTheme"
    private let unlockedKey = "unlockedThemes"

    var selected: AppTheme {
        didSet { UserDefaults.standard.set(selected.rawValue, forKey: selectedKey) }
    }
    private(set) var unlocked: Set<String> {
        didSet { UserDefaults.standard.set(Array(unlocked), forKey: unlockedKey) }
    }

    private init() {
        selected = AppTheme(rawValue: UserDefaults.standard.string(forKey: selectedKey) ?? "") ?? .leaf
        unlocked = Set(UserDefaults.standard.stringArray(forKey: unlockedKey) ?? []).union([AppTheme.leaf.rawValue])
    }

    func isUnlocked(_ theme: AppTheme) -> Bool {
        theme.isFree || unlocked.contains(theme.rawValue)
    }

    func unlock(_ theme: AppTheme) {
        unlocked.insert(theme.rawValue)
    }
}
