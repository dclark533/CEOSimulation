import XCTest
@testable import CEOSimulationCore

@MainActor
final class DepartmentNeglectTests: XCTestCase {
    func testInitialNotNeglected() {
        let dept = Department(type: .sales)
        XCTAssertEqual(dept.quartersSinceLastInvestment, 0)
        XCTAssertFalse(dept.isNeglected)
    }

    func testNeglectedAfterThreshold() {
        let dept = Department(type: .engineering)
        dept.quartersSinceLastInvestment = GameConstants.neglectThresholdQuarters
        XCTAssertTrue(dept.isNeglected)
    }

    func testNotNeglectedBelowThreshold() {
        let dept = Department(type: .marketing)
        dept.quartersSinceLastInvestment = GameConstants.neglectThresholdQuarters - 1
        XCTAssertFalse(dept.isNeglected)
    }

    func testDecayAppliesWhenNeglected() {
        let dept = Department(type: .hr)
        dept.performance = 60
        dept.morale = 60
        dept.quartersSinceLastInvestment = GameConstants.neglectThresholdQuarters
        dept.applyNeglectDecay()
        XCTAssertLessThan(dept.performance, 60)
        XCTAssertLessThan(dept.morale, 60)
    }

    func testDecayDoesNotApplyWhenNotNeglected() {
        let dept = Department(type: .finance)
        dept.performance = 60
        dept.morale = 60
        dept.quartersSinceLastInvestment = 0
        dept.applyNeglectDecay()
        XCTAssertEqual(dept.performance, 60)
        XCTAssertEqual(dept.morale, 60)
    }

    func testPositiveDecisionResetsCounter() {
        let dept = Department(type: .sales)
        dept.quartersSinceLastInvestment = 5
        let impact = DecisionImpact(performanceChange: 5)
        dept.applyDecisionImpact(impact)
        XCTAssertEqual(dept.quartersSinceLastInvestment, 0)
    }

    func testNegativeDecisionDoesNotResetCounter() {
        let dept = Department(type: .sales)
        dept.quartersSinceLastInvestment = 3
        let impact = DecisionImpact(performanceChange: -5, moraleChange: -3, budgetChange: -1000)
        dept.applyDecisionImpact(impact)
        XCTAssertEqual(dept.quartersSinceLastInvestment, 3)
    }

    func testQuarterAdvanceIncrementsCounter() {
        let dept = Department(type: .engineering)
        XCTAssertEqual(dept.quartersSinceLastInvestment, 0)
        dept.generateQuarterlyReport()
        XCTAssertEqual(dept.quartersSinceLastInvestment, 1)
        dept.generateQuarterlyReport()
        XCTAssertEqual(dept.quartersSinceLastInvestment, 2)
    }

    func testDecayScalesWithDuration() {
        let dept1 = Department(type: .sales)
        dept1.performance = 80
        dept1.morale = 80
        dept1.quartersSinceLastInvestment = GameConstants.neglectThresholdQuarters

        let dept2 = Department(type: .sales)
        dept2.performance = 80
        dept2.morale = 80
        dept2.quartersSinceLastInvestment = GameConstants.neglectThresholdQuarters + 2

        dept1.applyNeglectDecay()
        dept2.applyNeglectDecay()

        // dept2 neglected longer, so should have more decay
        XCTAssertLessThan(dept2.performance, dept1.performance)
        XCTAssertLessThan(dept2.morale, dept1.morale)
    }

    func testDecayClampsAtMinimum() {
        let dept = Department(type: .finance)
        dept.performance = 1
        dept.morale = 1
        dept.quartersSinceLastInvestment = 10
        dept.applyNeglectDecay()
        XCTAssertGreaterThanOrEqual(dept.performance, GameConstants.metricMin)
        XCTAssertGreaterThanOrEqual(dept.morale, GameConstants.metricMin)
    }
}
