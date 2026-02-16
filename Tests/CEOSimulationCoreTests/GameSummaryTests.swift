import XCTest
@testable import CEOSimulationCore

@MainActor
final class GameSummaryTests: XCTestCase {
    func testSuccessfulRun() {
        let summary = GameSummary(
            quartersSurvived: 10,
            scenariosCompleted: 40,
            currentScore: 750,
            finalBudget: 80000,
            finalReputation: 65,
            finalPerformance: 70,
            strongestDepartment: .engineering,
            gameEndReason: "Game completed"
        )
        XCTAssertTrue(summary.isSuccessfulRun)
    }

    func testUnsuccessfulRun() {
        let summary = GameSummary(
            quartersSurvived: 3,
            scenariosCompleted: 12,
            currentScore: 200,
            finalBudget: 10000,
            finalReputation: 20,
            finalPerformance: 30,
            strongestDepartment: .sales,
            gameEndReason: "Company ran out of money!"
        )
        XCTAssertFalse(summary.isSuccessfulRun)
    }

    func testPerformanceGrades() {
        let gradeTests: [(Int, String)] = [
            (950, "A+"),
            (850, "A"),
            (750, "B+"),
            (650, "B"),
            (550, "C+"),
            (450, "C"),
            (300, "D"),
            (100, "F"),
        ]

        for (score, expectedGrade) in gradeTests {
            let summary = GameSummary(
                quartersSurvived: 5,
                scenariosCompleted: 20,
                currentScore: score,
                finalBudget: 50000,
                finalReputation: 50,
                finalPerformance: 50,
                strongestDepartment: .sales,
                gameEndReason: "Test"
            )
            XCTAssertEqual(summary.performanceGrade, expectedGrade, "Score \(score) should give grade \(expectedGrade)")
        }
    }

    func testSummaryMessages() {
        // Successful run message
        let successful = GameSummary(
            quartersSurvived: 10,
            scenariosCompleted: 40,
            currentScore: 700,
            finalBudget: 60000,
            finalReputation: 50,
            finalPerformance: 60,
            strongestDepartment: .marketing,
            gameEndReason: "Completed"
        )
        XCTAssertTrue(successful.summaryMessage.contains("Congratulations"))

        // Mid-run message
        let midRun = GameSummary(
            quartersSurvived: 6,
            scenariosCompleted: 24,
            currentScore: 400,
            finalBudget: 20000,
            finalReputation: 25,
            finalPerformance: 40,
            strongestDepartment: .hr,
            gameEndReason: "Budget ran out"
        )
        XCTAssertTrue(midRun.summaryMessage.contains("Good effort"))

        // Early failure message
        let earlyFail = GameSummary(
            quartersSurvived: 2,
            scenariosCompleted: 8,
            currentScore: 150,
            finalBudget: 5000,
            finalReputation: 15,
            finalPerformance: 20,
            strongestDepartment: .finance,
            gameEndReason: "Budget ran out"
        )
        XCTAssertTrue(earlyFail.summaryMessage.contains("experience"))
    }

    func testNewFieldsDefaultValues() {
        let summary = GameSummary(
            quartersSurvived: 5,
            scenariosCompleted: 20,
            currentScore: 500,
            finalBudget: 50000,
            finalReputation: 50,
            finalPerformance: 50,
            strongestDepartment: .sales,
            gameEndReason: "Test"
        )
        XCTAssertEqual(summary.highRiskDecisionsTaken, 0)
        XCTAssertEqual(summary.highRiskSuccesses, 0)
        XCTAssertTrue(summary.neglectedDepartments.isEmpty)
    }

    func testNewFieldsWithValues() {
        let summary = GameSummary(
            quartersSurvived: 8,
            scenariosCompleted: 32,
            currentScore: 600,
            finalBudget: 45000,
            finalReputation: 55,
            finalPerformance: 60,
            strongestDepartment: .engineering,
            gameEndReason: "Completed",
            highRiskDecisionsTaken: 5,
            highRiskSuccesses: 3,
            neglectedDepartments: [.hr, .finance]
        )
        XCTAssertEqual(summary.highRiskDecisionsTaken, 5)
        XCTAssertEqual(summary.highRiskSuccesses, 3)
        XCTAssertEqual(summary.neglectedDepartments.count, 2)
    }
}
