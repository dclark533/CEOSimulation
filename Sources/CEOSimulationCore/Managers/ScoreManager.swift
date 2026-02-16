import Foundation

public struct ScoreBreakdown: Sendable {
    public let baseScore: Int
    public let longevityBonus: Int
    public let consistencyBonus: Int
    public let efficiencyBonus: Int
    public let riskRewardBonus: Int
    public let departmentBalanceBonus: Int
    public let totalScore: Int

    public init(baseScore: Int, longevityBonus: Int, consistencyBonus: Int, efficiencyBonus: Int, riskRewardBonus: Int, departmentBalanceBonus: Int) {
        self.baseScore = baseScore
        self.longevityBonus = longevityBonus
        self.consistencyBonus = consistencyBonus
        self.efficiencyBonus = efficiencyBonus
        self.riskRewardBonus = riskRewardBonus
        self.departmentBalanceBonus = departmentBalanceBonus
        self.totalScore = max(0, baseScore + longevityBonus + consistencyBonus + efficiencyBonus + riskRewardBonus + departmentBalanceBonus)
    }
}

@MainActor
public class ScoreManager {
    private var decisionHistory: [ScoredDecision] = []
    private var performanceMetrics: PerformanceMetrics = PerformanceMetrics()

    public init() {}

    public func recordDecision(_ decision: DecisionOption, for company: Company, riskLevel: RiskLevel = .medium, actualImpact: DecisionImpact? = nil) {
        let scoredDecision = ScoredDecision(
            decision: decision,
            quarterMade: company.quarter,
            companyStateBefore: CompanySnapshot(from: company),
            timestamp: Date(),
            riskLevel: riskLevel,
            actualImpact: actualImpact
        )

        decisionHistory.append(scoredDecision)
        updatePerformanceMetrics(company)
    }

    public func calculateScore(for company: Company) -> Int {
        return getScoreBreakdown(for: company).totalScore
    }

    public func getScoreBreakdown(for company: Company) -> ScoreBreakdown {
        let base = calculateBaseScore(company)
        let longevity = calculateLongevityBonus(company)
        let consistency = calculateConsistencyBonus()
        let efficiency = calculateEfficiencyBonus()
        let riskReward = calculateRiskRewardBonus()
        let balance = calculateDepartmentBalanceBonus(company)

        return ScoreBreakdown(
            baseScore: base,
            longevityBonus: longevity,
            consistencyBonus: consistency,
            efficiencyBonus: efficiency,
            riskRewardBonus: riskReward,
            departmentBalanceBonus: balance
        )
    }

    private func calculateBaseScore(_ company: Company) -> Int {
        let budgetScore = min(Int(GameConstants.metricMax), max(0, Int(company.budget / GameConstants.budgetScoreDivisor)))
        let reputationScore = Int(company.reputation * GameConstants.reputationScoreMultiplier)
        let performanceScore = Int(company.overallPerformance * GameConstants.performanceScoreMultiplier)
        let departmentScore = company.departments.map { Int($0.performance + $0.morale) / 2 }.reduce(0, +)

        return budgetScore + reputationScore + performanceScore + departmentScore
    }

    private func calculateLongevityBonus(_ company: Company) -> Int {
        return company.quarter * GameConstants.longevityBonusPerQuarter
    }

    private func calculateConsistencyBonus() -> Int {
        guard decisionHistory.count >= GameConstants.consistencyMinDecisions else { return 0 }

        let recentDecisions = Array(decisionHistory.suffix(GameConstants.consistencyRecentCount))
        let balancedDecisions = recentDecisions.filter { decision in
            abs(decision.decision.impact.performanceChange) <= GameConstants.consistencyPerformanceThreshold &&
            abs(decision.decision.impact.reputationChange) <= GameConstants.consistencyReputationThreshold
        }.count

        return balancedDecisions * GameConstants.consistencyBonusPerDecision
    }

    private func calculateEfficiencyBonus() -> Int {
        let lowCostHighImpactDecisions = decisionHistory.filter { decision in
            decision.decision.cost <= GameConstants.efficiencyCostThreshold &&
            (decision.decision.impact.performanceChange > GameConstants.efficiencyPerformanceThreshold || decision.decision.impact.reputationChange > GameConstants.efficiencyReputationThreshold)
        }.count

        return lowCostHighImpactDecisions * GameConstants.efficiencyBonusPerDecision
    }

    public func calculateRiskRewardBonus() -> Int {
        var bonus = 0
        for decision in decisionHistory {
            guard let actual = decision.actualImpact else { continue }
            let isSuccess = actual.performanceChange >= 0 || actual.reputationChange >= 0
            if decision.riskLevel == .high && isSuccess {
                bonus += GameConstants.highRiskSuccessBonus
            } else if decision.riskLevel == .medium && isSuccess {
                bonus += GameConstants.mediumRiskSuccessBonus
            }
        }
        return bonus
    }

    public func calculateDepartmentBalanceBonus(_ company: Company) -> Int {
        let allAboveThreshold = company.departments.allSatisfy {
            $0.performance >= GameConstants.departmentBalanceThreshold
        }
        return allAboveThreshold ? GameConstants.departmentBalanceBonus : 0
    }

    private func updatePerformanceMetrics(_ company: Company) {
        performanceMetrics.totalBudgetSpent += decisionHistory.last?.decision.cost ?? 0
        performanceMetrics.averagePerformance = company.departments.map(\.performance).reduce(0, +) / Double(company.departments.count)
        performanceMetrics.averageMorale = company.departments.map(\.morale).reduce(0, +) / Double(company.departments.count)
        performanceMetrics.currentReputation = company.reputation
    }

    public func getPerformanceAnalysis(for company: Company) -> PerformanceAnalysis {
        return PerformanceAnalysis(
            totalScore: calculateScore(for: company),
            quartersSurvived: company.quarter,
            decisionsMade: decisionHistory.count,
            averageDecisionCost: decisionHistory.isEmpty ? 0 : decisionHistory.map(\.decision.cost).reduce(0, +) / Double(decisionHistory.count),
            strongestDepartment: findStrongestDepartment(company),
            weakestDepartment: findWeakestDepartment(company),
            keyStrengths: identifyStrengths(company),
            areasForImprovement: identifyWeaknesses(company),
            leadershipStyle: determineLeadershipStyle()
        )
    }

    private func findStrongestDepartment(_ company: Company) -> DepartmentType {
        return company.departments.max(by: { $0.performance < $1.performance })?.type ?? .sales
    }

    private func findWeakestDepartment(_ company: Company) -> DepartmentType {
        return company.departments.min(by: { $0.performance < $1.performance })?.type ?? .sales
    }

    private func identifyStrengths(_ company: Company) -> [String] {
        var strengths: [String] = []

        if company.budget > GameConstants.strongBudgetThreshold {
            strengths.append("Strong Financial Management")
        }

        if company.reputation > GameConstants.strongReputationThreshold {
            strengths.append("Excellent Brand Reputation")
        }

        if company.overallPerformance > GameConstants.strongPerformanceThreshold {
            strengths.append("High-Performance Operations")
        }

        if company.departments.allSatisfy({ $0.morale > GameConstants.strongMoraleThreshold }) {
            strengths.append("Great Team Morale")
        }

        if calculateConsistencyBonus() > GameConstants.consistencyBonusStrengthThreshold {
            strengths.append("Consistent Decision Making")
        }

        return strengths.isEmpty ? ["Resilience Under Pressure"] : strengths
    }

    private func identifyWeaknesses(_ company: Company) -> [String] {
        var weaknesses: [String] = []

        if company.budget < GameConstants.weakBudgetThreshold {
            weaknesses.append("Cash Flow Management")
        }

        if company.reputation < GameConstants.weakReputationThreshold {
            weaknesses.append("Brand Reputation Recovery")
        }

        if company.overallPerformance < GameConstants.weakPerformanceThreshold {
            weaknesses.append("Operational Efficiency")
        }

        let lowMoraleDepts = company.departments.filter { $0.morale < GameConstants.weakMoraleThreshold }.count
        if lowMoraleDepts > 1 {
            weaknesses.append("Employee Satisfaction")
        }

        if decisionHistory.count > GameConstants.expensiveDecisionLookback {
            let expensiveDecisions = decisionHistory.suffix(GameConstants.expensiveDecisionLookback).filter { $0.decision.cost > GameConstants.expensiveDecisionThreshold }.count
            if expensiveDecisions > GameConstants.expensiveDecisionCountThreshold {
                weaknesses.append("Budget Optimization")
            }
        }

        return weaknesses.isEmpty ? ["Strategic Vision"] : weaknesses
    }

    private func determineLeadershipStyle() -> LeadershipStyle {
        guard !decisionHistory.isEmpty else { return .balanced }

        let totalDecisions = decisionHistory.count
        let aggressiveDecisions = decisionHistory.filter { $0.decision.cost > GameConstants.aggressiveCostThreshold }.count
        let conservativeDecisions = decisionHistory.filter { $0.decision.cost == 0 }.count

        let aggressiveRatio = Double(aggressiveDecisions) / Double(totalDecisions)
        let conservativeRatio = Double(conservativeDecisions) / Double(totalDecisions)

        if aggressiveRatio > GameConstants.leadershipStyleRatioThreshold {
            return .aggressive
        } else if conservativeRatio > GameConstants.leadershipStyleRatioThreshold {
            return .conservative
        } else {
            return .balanced
        }
    }

    public func getDecisionHistory() -> [ScoredDecision] {
        return decisionHistory
    }

    public func getTopPerformingDecisions() -> [ScoredDecision] {
        return decisionHistory
            .filter { $0.decision.impact.performanceChange > 5 || $0.decision.impact.reputationChange > 3 }
            .sorted { $0.decision.impact.performanceChange > $1.decision.impact.performanceChange }
            .prefix(5)
            .map { $0 }
    }

    public func getHighRiskStats() -> (taken: Int, successes: Int) {
        let highRisk = decisionHistory.filter { $0.riskLevel == .high }
        let successes = highRisk.filter { scored in
            guard let actual = scored.actualImpact else { return false }
            return actual.performanceChange >= 0 || actual.reputationChange >= 0
        }.count
        return (taken: highRisk.count, successes: successes)
    }
}

public struct ScoredDecision: Sendable {
    public let decision: DecisionOption
    public let quarterMade: Int
    public let companyStateBefore: CompanySnapshot
    public let timestamp: Date
    public let riskLevel: RiskLevel
    public let actualImpact: DecisionImpact?

    public init(decision: DecisionOption, quarterMade: Int, companyStateBefore: CompanySnapshot, timestamp: Date, riskLevel: RiskLevel = .medium, actualImpact: DecisionImpact? = nil) {
        self.decision = decision
        self.quarterMade = quarterMade
        self.companyStateBefore = companyStateBefore
        self.timestamp = timestamp
        self.riskLevel = riskLevel
        self.actualImpact = actualImpact
    }
}

public struct CompanySnapshot: Sendable {
    public let budget: Double
    public let reputation: Double
    public let overallPerformance: Double
    public let departmentPerformances: [DepartmentType: Double]

    @MainActor
    public init(from company: Company) {
        self.budget = company.budget
        self.reputation = company.reputation
        self.overallPerformance = company.overallPerformance
        self.departmentPerformances = Dictionary(uniqueKeysWithValues:
            company.departments.map { ($0.type, $0.performance) })
    }
}

public struct PerformanceMetrics: Sendable {
    public var totalBudgetSpent: Double = 0
    public var averagePerformance: Double = 50
    public var averageMorale: Double = 50
    public var currentReputation: Double = 50

    public init() {}
}

public struct PerformanceAnalysis: Sendable {
    public let totalScore: Int
    public let quartersSurvived: Int
    public let decisionsMade: Int
    public let averageDecisionCost: Double
    public let strongestDepartment: DepartmentType
    public let weakestDepartment: DepartmentType
    public let keyStrengths: [String]
    public let areasForImprovement: [String]
    public let leadershipStyle: LeadershipStyle

    public init(
        totalScore: Int,
        quartersSurvived: Int,
        decisionsMade: Int,
        averageDecisionCost: Double,
        strongestDepartment: DepartmentType,
        weakestDepartment: DepartmentType,
        keyStrengths: [String],
        areasForImprovement: [String],
        leadershipStyle: LeadershipStyle
    ) {
        self.totalScore = totalScore
        self.quartersSurvived = quartersSurvived
        self.decisionsMade = decisionsMade
        self.averageDecisionCost = averageDecisionCost
        self.strongestDepartment = strongestDepartment
        self.weakestDepartment = weakestDepartment
        self.keyStrengths = keyStrengths
        self.areasForImprovement = areasForImprovement
        self.leadershipStyle = leadershipStyle
    }
}

public enum LeadershipStyle: String, CaseIterable, Sendable {
    case aggressive = "Aggressive Growth"
    case conservative = "Conservative Steward"
    case balanced = "Balanced Strategic"

    public var description: String {
        switch self {
        case .aggressive:
            return "You make bold, high-investment decisions focused on rapid growth and market capture."
        case .conservative:
            return "You prefer measured, low-risk approaches that prioritize stability and gradual improvement."
        case .balanced:
            return "You balance risk and reward, making strategic decisions that consider multiple factors."
        }
    }
}
