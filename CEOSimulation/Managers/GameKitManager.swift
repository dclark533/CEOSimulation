import GameKit
import SwiftUI
import CEOSimulationCore

@MainActor
@Observable
final class GameKitManager {
    static let shared = GameKitManager()

    var isAuthenticated = false
    var authenticationError: String?

    // MARK: - Leaderboard & Achievement IDs

    private static let leaderboardID = "com.ceosimulation.leaderboard.totalscore"

    private enum AchievementID {
        static let firstQuarter = "com.ceosimulation.achievement.firstquarter"
        static let survivor = "com.ceosimulation.achievement.survivor"
        static let perfectRun = "com.ceosimulation.achievement.perfectrun"
        static let aPlusCEO = "com.ceosimulation.achievement.aplusceo"
        static let riskTaker = "com.ceosimulation.achievement.risktaker"
        static let balancedLeader = "com.ceosimulation.achievement.balancedleader"
    }

    private init() {}

    // MARK: - Authentication

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            Task { @MainActor in
                guard let self else { return }

                if let error {
                    self.authenticationError = error.localizedDescription
                    self.isAuthenticated = false
                    return
                }

                if let viewController {
                    #if os(iOS)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        rootVC.present(viewController, animated: true)
                    }
                    #elseif os(macOS)
                    if let window = NSApplication.shared.keyWindow {
                        window.contentViewController?.presentAsSheet(viewController)
                    }
                    #endif
                    return
                }

                self.isAuthenticated = GKLocalPlayer.local.isAuthenticated
                self.authenticationError = nil
            }
        }
    }

    // MARK: - Leaderboard

    func submitScore(_ score: Int) async {
        guard isAuthenticated else { return }
        do {
            try await GKLeaderboard.submitScore(
                score,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: [Self.leaderboardID]
            )
        } catch {
            print("Failed to submit score: \(error.localizedDescription)")
        }
    }

    // MARK: - Achievements

    func reportAchievements(for summary: GameSummary, scoreBreakdown: ScoreBreakdown) async {
        guard isAuthenticated else { return }

        var achievements: [GKAchievement] = []

        // First Quarter — survive 1+ quarters
        if summary.quartersSurvived >= 1 {
            let a = GKAchievement(identifier: AchievementID.firstQuarter)
            a.percentComplete = 100
            a.showsCompletionBanner = true
            achievements.append(a)
        }

        // Survivor — survive 8+ quarters (progressive)
        if summary.quartersSurvived >= 1 {
            let a = GKAchievement(identifier: AchievementID.survivor)
            a.percentComplete = min(100, Double(summary.quartersSurvived) / 8.0 * 100)
            a.showsCompletionBanner = true
            achievements.append(a)
        }

        // Perfect Run — complete all 12 quarters
        if summary.quartersSurvived >= 12 {
            let a = GKAchievement(identifier: AchievementID.perfectRun)
            a.percentComplete = 100
            a.showsCompletionBanner = true
            achievements.append(a)
        }

        // A+ CEO — score 900+
        if scoreBreakdown.totalScore >= 900 {
            let a = GKAchievement(identifier: AchievementID.aPlusCEO)
            a.percentComplete = 100
            a.showsCompletionBanner = true
            achievements.append(a)
        }

        // Risk Taker — take 5+ high-risk decisions (progressive)
        if summary.highRiskDecisionsTaken >= 1 {
            let a = GKAchievement(identifier: AchievementID.riskTaker)
            a.percentComplete = min(100, Double(summary.highRiskDecisionsTaken) / 5.0 * 100)
            a.showsCompletionBanner = true
            achievements.append(a)
        }

        // Balanced Leader — all departments above 50% at game end
        if summary.neglectedDepartments.isEmpty && summary.finalPerformance > 50 {
            let a = GKAchievement(identifier: AchievementID.balancedLeader)
            a.percentComplete = 100
            a.showsCompletionBanner = true
            achievements.append(a)
        }

        guard !achievements.isEmpty else { return }

        do {
            try await GKAchievement.report(achievements)
        } catch {
            print("Failed to report achievements: \(error.localizedDescription)")
        }
    }

    // MARK: - Access Point

    func showAccessPoint() {
        GKAccessPoint.shared.location = .topLeading
        GKAccessPoint.shared.isActive = true
    }

    func hideAccessPoint() {
        GKAccessPoint.shared.isActive = false
    }

    // MARK: - Dashboard

    func presentDashboard() {
        guard isAuthenticated else { return }

        let vc = GKGameCenterViewController(state: .default)

        #if os(iOS)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            vc.gameCenterDelegate = GameCenterDismissHandler.shared
            rootVC.present(vc, animated: true)
        }
        #elseif os(macOS)
        if let window = NSApplication.shared.keyWindow {
            vc.gameCenterDelegate = GameCenterDismissHandler.shared
            window.contentViewController?.presentAsSheet(vc)
        }
        #endif
    }
}

// MARK: - Dismiss Handler

private final class GameCenterDismissHandler: NSObject, GKGameCenterControllerDelegate {
    static let shared = GameCenterDismissHandler()

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        #if os(iOS)
        gameCenterViewController.dismiss(animated: true)
        #elseif os(macOS)
        gameCenterViewController.dismiss(nil)
        #endif
    }
}
