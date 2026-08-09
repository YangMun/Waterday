import Foundation
import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

/// AdMob configuration — same policy as Dayline:
/// DEBUG builds always use Google's sample ad units; RELEASE uses the real
/// units from the gitignored AdIDs.swift, and the developer's own device is
/// registered as a test device so it never generates invalid traffic.
enum AdConfig {
    #if DEBUG
    static let bannerUnitID = "ca-app-pub-3940256099942544/2934735716"
    static let rewardedUnitID = "ca-app-pub-3940256099942544/1712485313"
    #else
    static let bannerUnitID = AdIDs.bannerUnitID
    static let rewardedUnitID = AdIDs.rewardedUnitID
    #endif

    static let testDeviceIdentifiers = AdIDs.testDeviceIdentifiers

    /// Request throttles: a banner reloads at most once a minute even if the
    /// user hops between tabs, and a failed rewarded load isn't retried in a loop.
    static let bannerReloadInterval: TimeInterval = 60
    static let rewardedLoadCooldown: TimeInterval = 30
}

enum AdsManager {
    static func start() {
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = AdConfig.testDeviceIdentifiers
        MobileAds.shared.start()
    }

    static func requestTrackingAuthorization() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
    }

    static var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    }
}

/// Owns a single shared BannerView so SwiftUI view recreation (tab switches,
/// re-renders) never triggers a new ad request on its own.
final class BannerAdController {
    static let shared = BannerAdController()

    private(set) lazy var bannerView: BannerView = {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = AdConfig.bannerUnitID
        return banner
    }()
    private var lastLoad: Date?

    func loadIfNeeded() {
        bannerView.rootViewController = AdsManager.rootViewController ?? bannerView.rootViewController
        if let lastLoad, Date.now.timeIntervalSince(lastLoad) < AdConfig.bannerReloadInterval { return }
        lastLoad = .now
        bannerView.load(Request())
    }
}

@Observable
final class RewardedAdController: NSObject {
    static let shared = RewardedAdController()

    private var rewardedAd: RewardedAd?
    private var isLoading = false
    private var lastLoadAttempt: Date?

    func preload() {
        guard rewardedAd == nil, !isLoading else { return }
        if let lastLoadAttempt, Date.now.timeIntervalSince(lastLoadAttempt) < AdConfig.rewardedLoadCooldown { return }
        isLoading = true
        lastLoadAttempt = .now
        RewardedAd.load(with: AdConfig.rewardedUnitID, request: Request()) { [weak self] ad, _ in
            self?.rewardedAd = ad
            self?.isLoading = false
        }
    }

    /// Shows the rewarded ad; calls onReward only when the user earned the reward.
    func show(onReward: @escaping () -> Void) {
        guard let ad = rewardedAd, let root = AdsManager.rootViewController else {
            // No ad ready (e.g. offline). Don't punish the user for our missing ad.
            onReward()
            preload()
            return
        }
        ad.present(from: root) {
            onReward()
        }
        rewardedAd = nil
        preload()
    }
}

struct BannerAdView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        BannerAdController.shared.loadIfNeeded()
        return BannerAdController.shared.bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}
