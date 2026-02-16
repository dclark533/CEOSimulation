import XCTest
@testable import CEOSimulationCore

@MainActor
final class ScoreManagerTests: XCTestCase {
    var scoreManager: ScoreManager!
    var company: Company!

    override func setUp() {
        super.setUp()
        scoreManager = ScoreManager()
        company = Company()
    }

    override func tearDown() {
        scoreManager = nil
        company = nil
        super.tearDown()
    }

    func testCalculateScoreInitialCompany() {
        let score = scoreManager.calculateScore(for: company)
        XCTAssertGreaterThan(score, 0)
    }

    func testLongevityBonus() {
        let score1 = scoreManager.calculateScore(for: company)
        company.quarter = 5
        let score5 = scoreManager.calculateScore(for: company)
        // Quarter 5 should give a higher longevity bonus than quarter 1
        XCTAssertGreaterThan(score5, score1)
    }

    func testRecordDecision() {
        let option = DecisionOption(
            title: "Test",
            description: "Test decision",
            cost: 5000,
            impact: DecisionImpact(performanceChange: 5, budgetChange: -5000)
        )
        scoreManager.recordDecision(option, for: company)
        let history = scoreManager.getDecisionHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first?.decision.title, "Test")
    }

    func testConsistencyBonus() {
        // Record 4 balanced decisions
        for _ in 0..<4 {
            let option = DecisionOption(
                title: "Balanced",
                description: "A balanced decision",
                cost: 5000,
                impact: DecisionImpact(performanceChange: 3, reputationChange: 2)
            )
            scoreManager.recordDecision(option, for: company)
        }
        // Score should include consistency bonus
        let score = scoreManager.calculateScore(for: company)
        XCTAssertGreaterThan(score, 0)
    }

    func testEfficiencyBonus() {
        // Low cost, high impact decision
        let option = DecisionOption(
            title: "Efficient",
            description: "Low cost high impact",
            cost: 5000,
            impact: DecisionImpact(performanceChange: 8, budgetChange: -5000)
        )
        scoreManager.recordDecision(option, for: company)
        let history = scoreManager.getTopPerformingDecisions()
        XCTAssertEqual(history.count, 1)
    }

    func testLeadershipStyleBalanced() {
        // Mix of decisions
        let analysis = scoreManager.getPerformanceAnalysis(for: company)
        XCTAssertEqual(analysis.leadershipStyle, .balanced)
    }

    func testLeadershipStyleAggressive() {
        // Record mostly expensive decisions
        for _ in 0..<5 {
            let option = DecisionOption(
                title: "Big Spend",
                description: "Expensive",
                cost: 30000,
                impact: DecisionImpact(performanceChange: 10, budgetChange: -30000)
            )
            scoreManager.recordDecision(option, for: company)
        }
        let analysis = scoreManager.getPerformanceAnalysis(for: company)
        XCTAssertEqual(analysis.leadershipStyle, .aggressive)
    }

    func testLeadershipStyleConservative() {
        // Record mostly free decisions
        for _ in 0..<5 {
            let option = DecisionOption(
                title: "Free",
                description: "No cost",
                cost: 0,
                impact: DecisionImpact(performanceChange: -2, budgetChange: 0)
            )
            scoreManager.recordDecision(option, for: company)
        }
        let analysis = scoreManager.getPerformanceAnalysis(for: company)
        XCTAssertEqual(analysis.leadershipStyle, .conservative)
    }

    func testPerformanceAnalysis() {
        let analysis = scoreManager.getPerformanceAnalysis(for: company)
        XCTAssertGreaterThanOrEqual(analysis.totalScore, 0)
        XCTAssertEqual(analysis.quartersSurvived, company.quarter)
        XCTAssertFalse(analysis.keyStrengths.isEmpty)
    }

    func testIdentifyStrengths() {
        company.budget = 80000
        company.reputation = 75
        company.overallPerformance = 75
        for dept in company.departments {
            dept.morale = 65
        }
        let analysis = scoreManager.getPerformanceAnalysis(for: company)
        XCTAssertTrue(analysis.keyStrengths.contains("Strong Financial Management"))
        XCTAssertTrue(analysis.keyStrengths.contains("Excellent Brand Reputation"))
        XCTAssertTrue(analysis.keyStrengths.contains("High-Performance Operations"))
        XCTAssertTrue(analysis.keyStrengths.contains("Great Team Morale"))
    }

    func testIdentifyWeaknesses() {
        company.budget = 20000
        company.reputation = 30
        company.overallPerformance = 30
        let analysis = scoreManager.getPerformanceAnalysis(for: company)
        XCTAssertTrue(analysis.areasForImprovement.contains("Cash Flow Management"))
        XCTAssertTrue(analysis.areasForImprovement.contains("Brand Reputation Recovery"))
        XCTAssertTrue(analysis.areasForImprovement.contains("Operational Efficiency"))
    }

    func testRiskRewardBonusHighRisk() {
        let option = DecisionOption(
            title: "Risky",
            description: "High risk decision",
            cost: 20000,
            impact: DecisionImpact(performanceChange: 10, budgetChange: -20000),
            riskLevel: .high
        )
        let actualImpact = DecisionImpact(performanceChange: 8, budgetChange: -20000)
        scoreManager.recordDecision(option, for: company, riskLevel: .high, actualImpact: actualImpact)

        let bonus = scoreManager.calculateRiskRewardBonus()
        XCTAssertEqual(bonus, GameConstants.highRiskSuccessBonus)
    }

    func testRiskRewardBonusMediumRisk() {
        let option = DecisionOption(
            title: "Moderate",
            description: "Medium risk decision",
            cost: 10000,
            impact: DecisionImpact(performanceChange: 5, budgetChange: -10000),
            riskLevel: .medium
        )
        let actualImpact = DecisionImpact(performanceChange: 4, reputationChange: 2)
        scoreManager.recordDecision(option, for: company, riskLevel: .medium, actualImpact: actualImpact)

        let bonus = scoreManager.calculateRiskRewardBonus()
        XCTAssertEqual(bonus, GameConstants.mediumRiskSuccessBonus)
    }

    func testRiskRewardBonusFailedDecision() {
        let option = DecisionOption(
            title: "Failed",
            description: "Failed high risk",
            cost: 20000,
            impact: DecisionImpact(performanceChange: 10),
            riskLevel: .high
        )
        let actualImpact = DecisionImpact(performanceChange: -5, reputationChange: -3)
        scoreManager.recordDecision(option, for: company, riskLevel: .high, actualImpact: actualImpact)

        let bonus = scoreManager.calculateRiskRewardBonus()
        XCTAssertEqual(bonus, 0)
    }

    func testDepartmentBalanceBonusAllAboveThreshold() {
        for dept in company.departments {
            dept.performance = GameConstants.departmentBalanceThreshold + 10
        }
        let bonus = scoreManager.calculateDepartmentBalanceBonus(company)
        XCTAssertEqual(bonus, GameConstants.departmentBalanceBonus)
    }

    func testDepartmentBalanceBonusOneBelowThreshold() {
        for dept in company.departments {
            dept.performance = GameConstants.departmentBalanceThreshold + 10
        }
        company.departments.first!.performance = GameConstants.departmentBalanceThreshold - 1
        let bonus = scoreManager.calculateDepartmentBalanceBonus(company)
        XCTAssertEqual(bonus, 0)
    }

    func testScoreBreakdownComponents() {
        let breakdown = scoreManager.getScoreBreakdown(for: company)
        XCTAssertGreaterThanOrEqual(breakdown.baseScore, 0)
        XCTAssertGreaterThanOrEqual(breakdown.longevityBonus, 0)
        XCTAssertEqual(breakdown.totalScore, breakdown.baseScore + breakdown.longevityBonus + breakdown.consistencyBonus + breakdown.efficiencyBonus + breakdown.riskRewardBonus + breakdown.departmentBalanceBonus)
    }

    func testHighRiskStats() {
        let option = DecisionOption(
            title: "Risky",
            description: "High risk",
            cost: 20000,
            impact: DecisionImpact(performanceChange: 10),
            riskLevel: .high
        )
        scoreManager.recordDecision(option, for: company, riskLevel: .high, actualImpact: DecisionImpact(performanceChange: 8))
        scoreManager.recordDecision(option, for: company, riskLevel: .high, actualImpact: DecisionImpact(performanceChange: -5, reputationChange: -3))

        let stats = scoreManager.getHighRiskStats()
        XCTAssertEqual(stats.taken, 2)
        XCTAssertEqual(stats.successes, 1)
    }
}
