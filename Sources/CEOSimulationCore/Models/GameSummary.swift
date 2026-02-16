import Foundation

public struct GameSummary: Sendable {
    public let quartersSurvived: Int
    public let scenariosCompleted: Int
    public let currentScore: Int
    public let finalBudget: Double
    public let finalReputation: Double
    public let finalPerformance: Double
    public let strongestDepartment: DepartmentType
    public let gameEndReason: String

    public init(
        quartersSurvived: Int,
        scenariosCompleted: Int,
        currentScore: Int,
        finalBudget: Double,
        finalReputation: Double,
        finalPerformance: Double,
        strongestDepartment: DepartmentType,
        gameEndReason: String
    ) {
        self.quartersSurvived = quartersSurvived
        self.scenariosCompleted = scenariosCompleted
        self.currentScore = currentScore
        self.finalBudget = finalBudget
        self.finalReputation = finalReputation
        self.finalPerformance = finalPerformance
        self.strongestDepartment = strongestDepartment
        self.gameEndReason = gameEndReason
    }

    public var isSuccessfulRun: Bool {
        return quartersSurvived >= 8 && finalBudget > 25000 && finalReputation > 30
    }

    public var performanceGrade: String {
        let score = currentScore
        if score >= 800 { return "A+" }
        else if score >= 700 { return "A" }
        else if score >= 600 { return "B+" }
        else if score >= 500 { return "B" }
        else if score >= 400 { return "C+" }
        else if score >= 300 { return "C" }
        else if score >= 200 { return "D" }
        else { return "F" }
    }

    public var summaryMessage: String {
        if isSuccessfulRun {
            return "Congratulations! You successfully led the company through challenging times and demonstrated strong leadership skills."
        } else if quartersSurvived >= 4 {
            return "Good effort! You managed to keep the company running for several quarters. With more experience, you'll achieve even better results."
        } else {
            return "Every great CEO learns from experience. Use the insights from this run to make better strategic decisions next time!"
        }
    }
}
