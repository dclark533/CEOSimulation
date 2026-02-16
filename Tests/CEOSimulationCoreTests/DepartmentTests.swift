import XCTest
@testable import CEOSimulationCore

@MainActor
final class DepartmentTests: XCTestCase {
    func testInitialPerformanceRange() {
        for _ in 0..<20 {
            let dept = Department(type: .sales)
            XCTAssertGreaterThanOrEqual(dept.performance, GameConstants.departmentPerformanceRange.lowerBound)
            XCTAssertLessThanOrEqual(dept.performance, GameConstants.departmentPerformanceRange.upperBound)
        }
    }

    func testInitialMoraleRange() {
        for _ in 0..<20 {
            let dept = Department(type: .engineering)
            XCTAssertGreaterThanOrEqual(dept.morale, GameConstants.departmentMoraleRange.lowerBound)
            XCTAssertLessThanOrEqual(dept.morale, GameConstants.departmentMoraleRange.upperBound)
        }
    }

    func testApplyPositiveImpact() {
        let dept = Department(type: .marketing)
        let initialPerformance = dept.performance
        let initialMorale = dept.morale
        let impact = DecisionImpact(performanceChange: 10, moraleChange: 5, budgetChange: 1000)
        dept.applyDecisionImpact(impact)
        XCTAssertEqual(dept.performance, initialPerformance + 10)
        XCTAssertEqual(dept.morale, initialMorale + 5)
        XCTAssertEqual(dept.budget, GameConstants.initialDepartmentBudget + 1000)
    }

    func testApplyNegativeImpact() {
        let dept = Department(type: .hr)
        let initialPerformance = dept.performance
        let initialMorale = dept.morale
        let impact = DecisionImpact(performanceChange: -10, moraleChange: -5, budgetChange: -1000)
        dept.applyDecisionImpact(impact)
        XCTAssertEqual(dept.performance, initialPerformance - 10)
        XCTAssertEqual(dept.morale, initialMorale - 5)
        XCTAssertEqual(dept.budget, GameConstants.initialDepartmentBudget - 1000)
    }

    func testPerformanceBoundsUpperClamp() {
        let dept = Department(type: .finance)
        dept.performance = 95
        let impact = DecisionImpact(performanceChange: 20)
        dept.applyDecisionImpact(impact)
        XCTAssertEqual(dept.performance, GameConstants.metricMax)
    }

    func testPerformanceBoundsLowerClamp() {
        let dept = Department(type: .finance)
        dept.performance = 5
        let impact = DecisionImpact(performanceChange: -20)
        dept.applyDecisionImpact(impact)
        XCTAssertEqual(dept.performance, GameConstants.metricMin)
    }

    func testMoraleBoundsUpperClamp() {
        let dept = Department(type: .sales)
        dept.morale = 95
        let impact = DecisionImpact(moraleChange: 20)
        dept.applyDecisionImpact(impact)
        XCTAssertEqual(dept.morale, GameConstants.metricMax)
    }

    func testMoraleBoundsLowerClamp() {
        let dept = Department(type: .sales)
        dept.morale = 5
        let impact = DecisionImpact(moraleChange: -20)
        dept.applyDecisionImpact(impact)
        XCTAssertEqual(dept.morale, GameConstants.metricMin)
    }

    func testGenerateQuarterlyReport() {
        let dept = Department(type: .engineering)
        let report = dept.generateQuarterlyReport()
        XCTAssertFalse(report.isEmpty)
        XCTAssertTrue(report.contains("Engineering"))
        XCTAssertEqual(dept.quarterlyReports.count, 1)
        // Generate a second report
        let report2 = dept.generateQuarterlyReport()
        XCTAssertEqual(dept.quarterlyReports.count, 2)
        XCTAssertTrue(report2.contains("Q2"))
    }
}
