import SwiftUI

enum LegalDocument: String, Identifiable {
    case privacyPolicy = "Privacy Policy"
    case terms = "Terms of Service"

    var id: String { rawValue }

    static let contactEmail = "yang486741@gmail.com"
    static let effectiveDate = "August 9, 2026"

    var body: String {
        switch self {
        case .privacyPolicy: Self.privacyPolicyText
        case .terms: Self.termsText
        }
    }

    private static let privacyPolicyText = """
    Effective date: \(effectiveDate)

    Waterday ("the app") is built around a simple promise: your plants are your business, not ours.

    1. Your data stays on your device
    Your plants, care history, and photos are stored only on your device. There is no account, no sign-up, and no server. We never see, collect, transmit, or back up any of it. If you delete the app, this data is deleted with it.

    2. What the app itself collects
    Nothing. The app has no analytics of its own. Settings (theme, reminder time, appearance) are stored on your device only.

    3. Photos
    Adding a plant photo uses the iOS photo picker, which runs outside the app — Waterday only receives the single photo you choose, and it is stored on your device only.

    4. Advertising
    Waterday is free and supported by ads served by Google AdMob. To serve and measure ads, Google may collect device information such as the advertising identifier (IDFA, only if you allow tracking), IP address, and ad interaction data, under Google's privacy policy:
    https://policies.google.com/privacy

    You can decline tracking when iOS asks ("Ask App Not to Track"). The app works exactly the same either way — you will simply see less personalized ads.

    5. Notifications
    The morning summary is a local notification scheduled on your device. No push notification service is used.

    6. Children
    Waterday is not directed at children under 13, and we do not knowingly collect personal information from children.

    7. Changes
    If this policy changes, the updated version will be included in an app update with a new effective date.

    8. Contact
    Questions or concerns: \(contactEmail)
    """

    private static let termsText = """
    Effective date: \(effectiveDate)

    By using Waterday, you agree to these terms.

    1. What Waterday is
    Waterday is a plant watering reminder and care log. It is provided free of charge, supported by advertising.

    2. Your content
    Your plant records and photos belong to you and are stored only on your device. Since there is no server, deleted data cannot be recovered by us.

    3. Not gardening advice
    Watering schedules are set by you. Waterday provides reminders, not horticultural advice, and is not responsible for the health of your plants.

    4. Advertising
    The app shows ads served by Google AdMob. Optional rewarded ads let you unlock cosmetic themes; watching them is always your choice.

    5. No warranty
    The app is provided "as is", without warranty of any kind. To the maximum extent permitted by law, the developer is not liable for any loss of data or damages arising from the use of the app.

    6. Changes
    These terms may be updated with app updates. Continued use after an update means you accept the revised terms.

    7. Contact
    \(contactEmail)
    """
}

struct LegalDocumentView: View {
    let document: LegalDocument

    var body: some View {
        ScrollView {
            Text(document.body)
                .font(.callout)
                .foregroundStyle(DS.textPrimary)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
        }
        .background(DS.bgApp)
        .navigationTitle(document.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}
