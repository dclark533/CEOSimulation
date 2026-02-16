import XCTest
@testable import CEOSimulationCore

@MainActor
final class CompanyTests: XCTestCase {
    func testInitialValues() {
        let company = Company()
        XCTAssertEqual(company.budget, GameConstants.initialBudget)
        XCTAssertEqual(company.reputation, GameConstants.initialReputation)
        XCTAssertEqual(company.overallPerformance, GameConstants.initialPerformance)
        XCTAssertEqual(company.quarter, 1)
    }

    func testDepartmentCount() {
        let company = Company()
        XCTAssertEqual(company.departments.count, 5)
        let types = Set(company.departments.map(\.type))
        XCTAssertEqual(types, Set(DepartmentType.allCases))
    }

    func testUpdateMetrics() {
        let company = Company()
        // Set known performance values
        for (i, dept) in company.departments.enumerated() {
            dept.performance = Double(i * 20) // 0, 20, 40, 60, 80
        }
        company.updateMetrics()
        let expected = (0.0 + 20.0 + 40.0 + 60.0 + 80.0) / 5.0
        XCTAssertEqual(company.overallPerformance, expected)
    }

    func testAdvanceQuarter() {
        let company = Company()
        let initialQuarter = company.quarter
        company.advanceQuarter()
        XCTAssertEqual(company.quarter, initialQuarter + 1)
        // Each department should have one quarterly report
        for dept in company.departments {
            XCTAssertEqual(dept.quarterlyReports.count, 1)
        }
    }

    func testAdvanceQuarterIncrementsNeglectCounters() {
        let company = Company()
        for dept in company.departments {
            XCTAssertEqual(dept.quartersSinceLastInvestment, 0)
        }
        company.advanceQuarter()
        for dept in company.departments {
            XCTAssertEqual(dept.quartersSinceLastInvestment, 1, "\(dept.type.rawValue) neglect counter should be 1 after advancing quarter")
        }
        company.advanceQuarter()
        for dept in company.departments {
            XCTAssertEqual(dept.quartersSinceLastInvestment, 2, "\(dept.type.rawValue) neglect counter should be 2 after advancing two quarters")
        }
    }
}
