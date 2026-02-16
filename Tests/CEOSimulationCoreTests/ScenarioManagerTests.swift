import XCTest
@testable import CEOSimulationCore

@MainActor
final class ScenarioManagerTests: XCTestCase {
    var scenarioManager: ScenarioManager!
    var company: Company!
    
    override func setUp() {
        super.setUp()
        scenarioManager = ScenarioManager()
        company = Company()
    }
    
    override func tearDown() {
        scenarioManager = nil
        company = nil
        super.tearDown()
    }
    
    func testScenarioGeneration() {
        let scenario = scenarioManager.generateScenario(for: company)
        
        XCTAssertFalse(scenario.title.isEmpty)
        XCTAssertFalse(scenario.description.isEmpty)
        XCTAssertGreaterThanOrEqual(scenario.options.count, 2)
        XCTAssertEqual(scenario.quarter, company.quarter)
    }
    
    func testScenarioOptionsHaveValidStructure() {
        let scenario = scenarioManager.generateScenario(for: company)
        
        for option in scenario.options {
            XCTAssertFalse(option.title.isEmpty)
            XCTAssertFalse(option.description.isEmpty)
            XCTAssertGreaterThanOrEqual(option.cost, 0)
        }
    }
    
    func testDifferentScenariosGenerated() {
        let scenario1 = scenarioManager.generateScenario(for: company)
        let scenario2 = scenarioManager.generateScenario(for: company)
        
        // While scenarios could be the same, with proper randomization they usually differ
        // This test may occasionally fail due to randomness, but helps verify variety
        let titlesAreDifferent = scenario1.title != scenario2.title
        let categoriesAreDifferent = scenario1.category != scenario2.category
        
        XCTAssertTrue(titlesAreDifferent || categoriesAreDifferent, "Scenarios should show variety")
    }
}