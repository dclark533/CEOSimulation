import Foundation

public enum DepartmentType: String, CaseIterable, Sendable {
    case sales = "Sales"
    case marketing = "Marketing"
    case engineering = "Engineering"
    case hr = "Human Resources"
    case finance = "Finance"

    public var icon: String {
        switch self {
        case .sales: return "chart.line.uptrend.xyaxis"
        case .marketing: return "megaphone"
        case .engineering: return "hammer"
        case .hr: return "person.2"
        case .finance: return "dollarsign.circle"
        }
    }
}

@MainActor
@Observable
public class Department {
    public let type: DepartmentType
    public var performance: Double
    public var morale: Double
    public var budget: Double
    public var quarterlyReports: [String]
    public var quartersSinceLastInvestment: Int = 0

    public var isNeglected: Bool {
        quartersSinceLastInvestment >= GameConstants.neglectThresholdQuarters
    }

    public init(type: DepartmentType) {
        self.type = type
        self.performance = Double.random(in: GameConstants.departmentPerformanceRange)
        self.morale = Double.random(in: GameConstants.departmentMoraleRange)
        self.budget = GameConstants.initialDepartmentBudget
        self.quarterlyReports = []
    }

    public func applyDecisionImpact(_ impact: DecisionImpact) {
        performance = max(GameConstants.metricMin, min(GameConstants.metricMax, performance + impact.performanceChange))
        morale = max(GameConstants.metricMin, min(GameConstants.metricMax, morale + impact.moraleChange))
        budget += impact.budgetChange

        if impact.performanceChange > 0 || impact.moraleChange > 0 || impact.budgetChange > 0 {
            recordInvestment()
        }
    }

    public func recordInvestment() {
        quartersSinceLastInvestment = 0
    }

    public func applyNeglectDecay() {
        guard isNeglected else { return }
        let neglectedQuarters = Double(quartersSinceLastInvestment - GameConstants.neglectThresholdQuarters + 1)
        let perfDecay = GameConstants.neglectPerformanceDecay * neglectedQuarters
        let moraleDecay = GameConstants.neglectMoraleDecay * neglectedQuarters
        performance = max(GameConstants.metricMin, performance + perfDecay)
        morale = max(GameConstants.metricMin, morale + moraleDecay)
    }

    @discardableResult
    public func generateQuarterlyReport() -> String {
        quartersSinceLastInvestment += 1
        let report = "\(type.rawValue) Q\(quarterlyReports.count + 1): Performance \(Int(performance))%, Morale \(Int(morale))%"
        quarterlyReports.append(report)
        return report
    }
}
