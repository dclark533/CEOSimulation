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
        // Generate several scenarios and check that we see at least 2 distinct titles
        var titles = Set<String>()
        for _ in 0..<10 {
            let scenario = scenarioManager.generateScenario(for: company)
            titles.insert(scenario.title)
        }
        XCTAssertGreaterThan(titles.count, 1, "10 scenarios should produce at least 2 distinct titles")
    }
}