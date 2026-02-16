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
            (850, "A+"),
            (750, "A"),
            (650, "B+"),
            (550, "B"),
            (450, "C+"),
            (350, "C"),
            (250, "D"),
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
}
