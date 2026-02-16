import Foundation

@MainActor
@Observable
public class GameController {
    public var company: Company
    public var currentScenario: Scenario?
    public var scenarioHistory: [Scenario]
    public var isGameActive: Bool
    public var gameOverReason: String?
    public var showingExitConfirmation: Bool = false
    public var currentMarketEvent: MarketEvent?
    public var marketEventQuartersRemaining: Int = 0

    private let scenarioManager: ScenarioManager
    private let scoreManager: ScoreManager

    public init() {
        self.company = Company()
        self.scenarioHistory = []
        self.isGameActive = false
        self.scenarioManager = ScenarioManager()
        self.scoreManager = ScoreManager()
    }

    public func startNewGame() {
        company = Company()
        scenarioHistory.removeAll()
        currentScenario = nil
        isGameActive = true
        gameOverReason = nil
        currentMarketEvent = nil
        marketEventQuartersRemaining = 0

        generateNextScenario()
    }

    public func makeDecision(_ optionIndex: Int) {
        guard let scenario = currentScenario,
              optionIndex < scenario.options.count else { return }

        let option = scenario.options[optionIndex]
        applyDecision(option)

        scenarioHistory.append(scenario)
        currentScenario = nil

        checkGameOver()

        if isGameActive {
            Task {
                try? await Task.sleep(for: .seconds(1))
                self.generateNextScenario()
            }
        }
    }

    private func applyDecision(_ option: DecisionOption) {
        let variedImpact = applyVariance(to: option.impact, option: option)

        company.budget += variedImpact.budgetChange
        company.reputation = max(GameConstants.metricMin, min(GameConstants.metricMax, company.reputation + variedImpact.reputationChange))

        if let specificDept = variedImpact.departmentSpecific {
            if let department = company.departments.first(where: { $0.type == specificDept }) {
                department.applyDecisionImpact(variedImpact)
            }
        } else {
            for department in company.departments {
                department.applyDecisionImpact(variedImpact)
            }
        }

        company.updateMetrics()
        scoreManager.recordDecision(option, for: company, riskLevel: option.riskLevel, actualImpact: variedImpact)
    }

    public func applyVariance(to impact: DecisionImpact, option: DecisionOption) -> DecisionImpact {
        let phase = DifficultyPhase.forQuarter(company.quarter)
        let variance = option.impactVariance * phase.varianceMultiplier

        func vary(_ value: Double) -> Double {
            guard variance > 0 && value != 0 else { return value }
            let factor = 1.0 + Double.random(in: -variance...variance)
            return value * factor
        }

        return DecisionImpact(
            performanceChange: vary(impact.performanceChange),
            moraleChange: vary(impact.moraleChange),
            budgetChange: vary(impact.budgetChange),
            reputationChange: vary(impact.reputationChange),
            departmentSpecific: impact.departmentSpecific
        )
    }

    private func generateNextScenario() {
        guard isGameActive else { return }

        if scenarioHistory.count > 0 && scenarioHistory.count % GameConstants.scenariosPerQuarter == 0 {
            applyNeglectDecay()
            applyMarketEventEffects()
            company.advanceQuarter()
            selectMarketEvent()
        }

        currentScenario = scenarioManager.generateScenario(for: company, marketEvent: currentMarketEvent)
    }

    private func selectMarketEvent() {
        if marketEventQuartersRemaining > 0 {
            marketEventQuartersRemaining -= 1
            if marketEventQuartersRemaining <= 0 {
                currentMarketEvent = nil
            }
            return
        }

        if let event = MarketEventPool.randomEvent() {
            currentMarketEvent = event
            marketEventQuartersRemaining = event.duration
        }
    }

    private func applyMarketEventEffects() {
        guard let event = currentMarketEvent else { return }
        let mod = event.modifier

        company.budget += mod.budgetDrain
        company.reputation = max(GameConstants.metricMin, min(GameConstants.metricMax, company.reputation + mod.reputationChange))

        for department in company.departments {
            department.performance = max(GameConstants.metricMin, min(GameConstants.metricMax, department.performance + mod.performanceChange))
            department.morale = max(GameConstants.metricMin, min(GameConstants.metricMax, department.morale + mod.moraleChange))
        }

        company.updateMetrics()
    }

    private func applyNeglectDecay() {
        for department in company.departments {
            department.applyNeglectDecay()
        }
        company.updateMetrics()
    }

    private func checkGameOver() {
        if company.budget < GameConstants.minBudget {
            endGame(reason: "Company ran out of money!")
        } else if company.reputation < GameConstants.minReputation {
            endGame(reason: "Company reputation fell too low!")
        } else if company.overallPerformance < GameConstants.minPerformance {
            endGame(reason: "Company performance declined beyond recovery!")
        } else if company.quarter > GameConstants.maxQuarters {
            endGame(reason: "Congratulations! You successfully managed the company for 3 years!")
        }
    }

    private func endGame(reason: String) {
        isGameActive = false
        gameOverReason = reason
        currentScenario = nil
    }

    public func getCurrentScore() -> Int {
        return scoreManager.calculateScore(for: company)
    }

    public func getScoreBreakdown() -> ScoreBreakdown {
        return scoreManager.getScoreBreakdown(for: company)
    }

    public func getPerformanceMetrics() -> [String: Double] {
        return [
            "Budget": company.budget,
            "Reputation": company.reputation,
            "Overall Performance": company.overallPerformance,
            "Quarter": Double(company.quarter)
        ]
    }

    public func requestExitGame() {
        showingExitConfirmation = true
    }

    public func confirmExitGame() {
        showingExitConfirmation = false
        exitToWelcomeScreen()
    }

    public func cancelExitGame() {
        showingExitConfirmation = false
    }

    public func exitToWelcomeScreen() {
        isGameActive = false
        currentScenario = nil
        gameOverReason = nil
    }

    public func pauseGame() {
        // Pause is a no-op in the current implementation;
        // the game naturally pauses when no decision is made.
    }

    public func getGameSummary() -> GameSummary {
        let strongest = company.departments.max(by: { $0.performance < $1.performance })?.type ?? .sales
        let riskStats = scoreManager.getHighRiskStats()
        let neglected = company.departments.filter { $0.isNeglected }.map(\.type)

        return GameSummary(
            quartersSurvived: company.quarter,
            scenariosCompleted: scenarioHistory.count,
            currentScore: getCurrentScore(),
            finalBudget: company.budget,
            finalReputation: company.reputation,
            finalPerformance: company.overallPerformance,
            strongestDepartment: strongest,
            gameEndReason: gameOverReason ?? "Game in progress",
            highRiskDecisionsTaken: riskStats.taken,
            highRiskSuccesses: riskStats.successes,
            neglectedDepartments: neglected
        )
    }
}
