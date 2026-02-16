import XCTest
@testable import CEOSimulationCore

@MainActor
final class DifficultyScalingTests: XCTestCase {
    func testPhaseDetectionStartup() {
        for q in 1...4 {
            XCTAssertEqual(DifficultyPhase.forQuarter(q), .startup, "Quarter \(q) should be startup")
        }
    }

    func testPhaseDetectionGrowth() {
        for q in 5...8 {
            XCTAssertEqual(DifficultyPhase.forQuarter(q), .growth, "Quarter \(q) should be growth")
        }
    }

    func testPhaseDetectionEnterprise() {
        for q in 9...12 {
            XCTAssertEqual(DifficultyPhase.forQuarter(q), .enterprise, "Quarter \(q) should be enterprise")
        }
    }

    func testImpactMultiplierOrdering() {
        XCTAssertLessThan(DifficultyPhase.startup.impactMultiplier, DifficultyPhase.growth.impactMultiplier)
        XCTAssertLessThan(DifficultyPhase.growth.impactMultiplier, DifficultyPhase.enterprise.impactMultiplier)
    }

    func testCostMultiplierOrdering() {
        XCTAssertLessThan(DifficultyPhase.startup.costMultiplier, DifficultyPhase.growth.costMultiplier)
        XCTAssertLessThan(DifficultyPhase.growth.costMultiplier, DifficultyPhase.enterprise.costMultiplier)
    }

    func testVarianceMultiplierOrdering() {
        XCTAssertLessThan(DifficultyPhase.startup.varianceMultiplier, DifficultyPhase.growth.varianceMultiplier)
        XCTAssertLessThan(DifficultyPhase.growth.varianceMultiplier, DifficultyPhase.enterprise.varianceMultiplier)
    }

    func testScenarioDifficultyScaling() {
        let manager = ScenarioManager()

        // Verify the scaling function directly using known inputs
        let baseOption = DecisionOption(
            title: "Test",
            description: "Test",
            cost: 10000,
            impact: DecisionImpact(performanceChange: 5)
        )
        let baseScenario = Scenario(
            category: .budget,
            title: "Test",
            description: "Test",
            options: [baseOption],
            quarter: 1
        )

        let scaledStartup = manager.applyDifficultyScaling(to: baseScenario, quarter: 2)
        let scaledEnterprise = manager.applyDifficultyScaling(to: baseScenario, quarter: 10)

        XCTAssertLessThan(scaledStartup.options[0].cost, scaledEnterprise.options[0].cost)
        XCTAssertLessThan(abs(scaledStartup.options[0].impact.performanceChange), abs(scaledEnterprise.options[0].impact.performanceChange))
    }
}
