import SwiftUI

struct SettingsView: View {
    @AppStorage("reminderEnabled") private var reminderEnabled = false
    @AppStorage("reminderMinutes") private var reminderMinutes = 9 * 60
    @AppStorage("appearance") private var appearance = "system"
    @Environment(\.modelContext) private var modelContext
    @State private var themeStore = ThemeStore.shared
    @State private var rewardedAds = RewardedAdController.shared
    @State private var notificationsDenied = false

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: reminderMinutes / 60,
                    minute: reminderMinutes % 60,
                    second: 0,
                    of: .now
                ) ?? .now
            },
            set: { newValue in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                reminderMinutes = (components.hour ?? 9) * 60 + (components.minute ?? 0)
            }
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DS.bgApp.ignoresSafeArea()
                List {
                    Section {
                        potRow
                    } header: {
                        GroundLabel("Pot Glaze")
                    }
                    Section {
                        ChipPicker(
                            options: [("system", "System"), ("dark", "Dark"), ("light", "Light")],
                            selection: $appearance
                        )
                        .padding(.vertical, 4)
                    } header: {
                        GroundLabel("Appearance")
                    }
                    Section {
                        Toggle("Morning summary", isOn: $reminderEnabled)
                        if reminderEnabled {
                            DatePicker("Time", selection: reminderTime, displayedComponents: .hourAndMinute)
                        }
                    } header: {
                        GroundLabel("Reminder")
                    } footer: {
                        Text("One notification per day, only when something actually needs water.")
                    }
                    Section {
                        LabeledContent("Data") {
                            Text("Stored only on this device")
                        }
                    } header: {
                        GroundLabel("Privacy")
                    }
                    Section {
                        Link(destination: URL(string: "mailto:\(LegalDocument.contactEmail)?subject=Waterday%20Feedback")!) {
                            LabeledContent("Contact Us") {
                                Text(verbatim: LegalDocument.contactEmail)
                            }
                        }
                    } header: {
                        GroundLabel("Support")
                    }
                    Section {
                        NavigationLink(LegalDocument.privacyPolicy.rawValue) {
                            LegalDocumentView(document: .privacyPolicy)
                        }
                        NavigationLink(LegalDocument.terms.rawValue) {
                            LegalDocumentView(document: .terms)
                        }
                    } header: {
                        GroundLabel("Legal")
                    }
                    Section {
                        LabeledContent("Version", value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0")
                        LabeledContent("Developer", value: "MunKyeong Yang")
                    } header: {
                        GroundLabel("About")
                    }
                }
                .scrollContentBackground(.hidden)
                .listRowSpacing(2)
                .safeAreaInset(edge: .top, spacing: 0) {
                    HStack {
                        Text("Settings")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(DS.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 4)
                    .background(DS.bgApp)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: reminderEnabled) { syncReminder() }
            .onChange(of: reminderMinutes) { syncReminder() }
            .alert("Notifications are off", isPresented: $notificationsDenied) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("To get the morning summary, allow notifications for Waterday in the iOS Settings app.")
            }
        }
    }

    private var potRow: some View {
        HStack(spacing: 12) {
            ForEach(AppTheme.allCases) { theme in
                Button {
                    selectOrUnlock(theme)
                } label: {
                    VStack(spacing: 8) {
                        Circle()
                            .fill(theme.color)
                            .frame(width: 44, height: 44)
                            .overlay {
                                if themeStore.selected == theme {
                                    Image(systemName: "checkmark")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(.white)
                                } else if !themeStore.isUnlocked(theme) {
                                    Image(systemName: "play.rectangle.fill")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.9))
                                }
                            }
                        Text(theme.name)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(themeStore.selected == theme ? DS.textPrimary : DS.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 6)
    }

    private func syncReminder() {
        CareActions.rescheduleReminders(context: modelContext) { authorized in
            if !authorized {
                reminderEnabled = false
                notificationsDenied = true
            }
        }
    }

    private func selectOrUnlock(_ theme: AppTheme) {
        if themeStore.isUnlocked(theme) {
            themeStore.selected = theme
        } else {
            rewardedAds.show {
                themeStore.unlock(theme)
                themeStore.selected = theme
            }
        }
    }
}
