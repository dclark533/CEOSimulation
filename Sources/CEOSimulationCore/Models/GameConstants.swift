import Foundation

public enum GameConstants {
    // MARK: - Initial Company Values
    public static let initialBudget: Double = 100_000
    public static let initialReputation: Double = 50
    public static let initialPerformance: Double = 50
    public static let initialDepartmentBudget: Double = 20_000

    // MARK: - Department Initialization
    public static let departmentPerformanceRange: ClosedRange<Double> = 40...60
    public static let departmentMoraleRange: ClosedRange<Double> = 40...60

    // MARK: - Game Mechanics
    public static let scenariosPerQuarter: Int = 4
    public static let maxQuarters: Int = 12

    // MARK: - Game Over Thresholds
    public static let minBudget: Double = 0
    public static let minReputation: Double = 10
    public static let minPerformance: Double = 10

    // MARK: - Metric Bounds
    public static let metricMin: Double = 0
    public static let metricMax: Double = 100

    // MARK: - Score Calculation
    public static let budgetScoreDivisor: Double = 1000
    public static let reputationScoreMultiplier: Double = 2
    public static let performanceScoreMultiplier: Double = 1.5
    public static let longevityBonusPerQuarter: Int = 10
    public static let consistencyMinDecisions: Int = 4
    public static let consistencyRecentCount: Int = 4
    public static let consistencyPerformanceThreshold: Double = 10
    public static let consistencyReputationThreshold: Double = 5
    public static let consistencyBonusPerDecision: Int = 5
    public static let efficiencyCostThreshold: Double = 10_000
    public static let efficiencyPerformanceThreshold: Double = 5
    public static let efficiencyReputationThreshold: Double = 3
    public static let efficiencyBonusPerDecision: Int = 15

    // MARK: - Scenario Category Weights
    public static let lowBudgetThreshold: Double = 50_000
    public static let lowReputationThreshold: Double = 30
    public static let lowPerformanceThreshold: Double = 40

    // MARK: - Analysis Thresholds
    public static let strongBudgetThreshold: Double = 75_000
    public static let strongReputationThreshold: Double = 70
    public static let strongPerformanceThreshold: Double = 70
    public static let strongMoraleThreshold: Double = 60
    public static let weakBudgetThreshold: Double = 30_000
    public static let weakReputationThreshold: Double = 40
    public static let weakPerformanceThreshold: Double = 40
    public static let weakMoraleThreshold: Double = 40

    // MARK: - Leadership Style Thresholds
    public static let aggressiveCostThreshold: Double = 25_000
    public static let leadershipStyleRatioThreshold: Double = 0.4
    public static let expensiveDecisionThreshold: Double = 20_000
    public static let expensiveDecisionLookback: Int = 8
    public static let expensiveDecisionCountThreshold: Int = 4
    public static let consistencyBonusStrengthThreshold: Int = 15

    // MARK: - Risk & Variance
    public static let lowVariance: Double = 0.08
    public static let mediumVariance: Double = 0.22
    public static let highVariance: Double = 0.40

    // MARK: - Difficulty Scaling (Startup Q1-4)
    public static let startupImpactMultiplier: Double = 0.7
    public static let startupCostMultiplier: Double = 0.6
    public static let startupVarianceMultiplier: Double = 0.7

    // MARK: - Difficulty Scaling (Growth Q5-8)
    public static let growthImpactMultiplier: Double = 1.0
    public static let growthCostMultiplier: Double = 1.0
    public static let growthVarianceMultiplier: Double = 1.0

    // MARK: - Difficulty Scaling (Enterprise Q9-12)
    public static let enterpriseImpactMultiplier: Double = 1.4
    public static let enterpriseCostMultiplier: Double = 1.3
    public static let enterpriseVarianceMultiplier: Double = 1.3

    // MARK: - Market Events
    public static let marketEventChance: Double = 0.4
    public static let marketEventMinDuration: Int = 1
    public static let marketEventMaxDuration: Int = 2

    // MARK: - Department Neglect
    public static let neglectThresholdQuarters: Int = 2
    public static let neglectPerformanceDecay: Double = -2.0
    public static let neglectMoraleDecay: Double = -3.0

    // MARK: - Enhanced Scoring
    public static let highRiskSuccessBonus: Int = 20
    public static let mediumRiskSuccessBonus: Int = 10
    public static let departmentBalanceBonus: Int = 30
    public static let departmentBalanceThreshold: Double = 50.0
}
