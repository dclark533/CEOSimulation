import XCTest
@testable import CEOSimulationCore

@MainActor
final class RiskVarianceTests: XCTestCase {
    func testLowVarianceRange() {
        let low = RiskLevel.low
        XCTAssertEqual(low.defaultVariance, GameConstants.lowVariance)
        XCTAssertLessThan(low.defaultVariance, 0.15)
    }

    func testMediumVarianceRange() {
        let medium = RiskLevel.medium
        XCTAssertEqual(medium.defaultVariance, GameConstants.mediumVariance)
        XCTAssertGreaterThan(medium.defaultVariance, GameConstants.lowVariance)
        XCTAssertLessThan(medium.defaultVariance, GameConstants.highVariance)
    }

    func testHighVarianceRange() {
        let high = RiskLevel.high
        XCTAssertEqual(high.defaultVariance, GameConstants.highVariance)
        XCTAssertGreaterThan(high.defaultVariance, 0.3)
    }

    func testVarianceOrdering() {
        XCTAssertLessThan(RiskLevel.low.defaultVariance, RiskLevel.medium.defaultVariance)
        XCTAssertLessThan(RiskLevel.medium.defaultVariance, RiskLevel.high.defaultVariance)
    }

    func testImpactHintsFromPositiveImpact() {
        let impact = DecisionImpact(performanceChange: 5, moraleChange: 3, reputationChange: 2)
        let hints = ImpactHint.fromImpact(impact)
        XCTAssertEqual(hints.count, 3)
        XCTAssertTrue(hints.allSatisfy { $0.direction == .positive })
    }

    func testImpactHintsFromNegativeImpact() {
        let impact = DecisionImpact(performanceChange: -5, moraleChange: -3, reputationChange: -2)
        let hints = ImpactHint.fromImpact(impact)
        XCTAssertEqual(hints.count, 3)
        XCTAssertTrue(hints.allSatisfy { $0.direction == .negative })
    }

    func testImpactHintsFromZeroImpact() {
        let impact = DecisionImpact(performanceChange: 0, moraleChange: 0, reputationChange: 0)
        let hints = ImpactHint.fromImpact(impact)
        XCTAssertTrue(hints.isEmpty)
    }

    func testImpactHintsMixedDirections() {
        let impact = DecisionImpact(performanceChange: 5, moraleChange: -3, reputationChange: 0)
        let hints = ImpactHint.fromImpact(impact)
        XCTAssertEqual(hints.count, 2)
        let perfHint = hints.first { $0.metric == "Performance" }
        let moraleHint = hints.first { $0.metric == "Morale" }
        XCTAssertEqual(perfHint?.direction, .positive)
        XCTAssertEqual(moraleHint?.direction, .negative)
    }

    func testRiskLevelIcons() {
        XCTAssertFalse(RiskLevel.low.icon.isEmpty)
        XCTAssertFalse(RiskLevel.medium.icon.isEmpty)
        XCTAssertFalse(RiskLevel.high.icon.isEmpty)
    }

    func testDecisionOptionDefaultRiskLevel() {
        let option = DecisionOption(
            title: "Test",
            description: "Test",
            cost: 0,
            impact: DecisionImpact()
        )
        XCTAssertEqual(option.riskLevel, .medium)
        XCTAssertEqual(option.impactVariance, 0.2)
    }
}
