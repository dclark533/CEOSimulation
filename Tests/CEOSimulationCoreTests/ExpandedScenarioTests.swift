import XCTest
@testable import CEOSimulationCore

@MainActor
final class ExpandedScenarioTests: XCTestCase {
    var manager: ScenarioManager!

    override func setUp() {
        super.setUp()
        manager = ScenarioManager()
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    func testNewCategoriesExist() {
        let categories = ScenarioCategory.allCases
        XCTAssertTrue(categories.contains(.ethical))
        XCTAssertTrue(categories.contains(.competitive))
        XCTAssertTrue(categories.contains(.innovation))
        XCTAssertTrue(categories.contains(.regulatory))
    }

    func testAllCategoriesHaveTemplates() {
        let company = Company()
        // Generate many scenarios to verify all categories can produce scenarios
        var categoriesSeen = Set<ScenarioCategory>()
        for _ in 0..<200 {
            let scenario = manager.generateScenario(for: company)
            categoriesSeen.insert(scenario.category)
        }
        // With 200 tries, we should see most categories
        XCTAssertGreaterThanOrEqual(categoriesSeen.count, 5, "Should see at least 5 different categories in 200 scenarios")
    }

    func testHighRiskOptionsHaveHighVariance() {
        let company = Company()
        var highRiskOptions: [DecisionOption] = []
        for _ in 0..<50 {
            let scenario = manager.generateScenario(for: company)
            highRiskOptions.append(contentsOf: scenario.options.filter { $0.riskLevel == .high })
        }

        if !highRiskOptions.isEmpty {
            for option in highRiskOptions {
                XCTAssertGreaterThanOrEqual(option.impactVariance, 0.3, "High-risk option '\(option.title)' should have variance >= 0.3")
            }
        }
    }

    func testLowRiskOptionsHaveLowVariance() {
        let company = Company()
        var lowRiskOptions: [DecisionOption] = []
        for _ in 0..<50 {
            let scenario = manager.generateScenario(for: company)
            lowRiskOptions.append(contentsOf: scenario.options.filter { $0.riskLevel == .low })
        }

        if !lowRiskOptions.isEmpty {
            for option in lowRiskOptions {
                XCTAssertLessThanOrEqual(option.impactVariance, 0.15, "Low-risk option '\(option.title)' should have variance <= 0.15")
            }
        }
    }

    func testScenariosHaveMultipleOptions() {
        let company = Company()
        for _ in 0..<20 {
            let scenario = manager.generateScenario(for: company)
            XCTAssertGreaterThanOrEqual(scenario.options.count, 2, "Scenario '\(scenario.title)' should have at least 2 options")
            XCTAssertLessThanOrEqual(scenario.options.count, 4, "Scenario '\(scenario.title)' should have at most 4 options")
        }
    }

    func testTotalCategoryCount() {
        XCTAssertEqual(ScenarioCategory.allCases.count, 9, "Should have 9 scenario categories")
    }
}
