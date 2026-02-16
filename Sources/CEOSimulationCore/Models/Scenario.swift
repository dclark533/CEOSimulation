import Foundation

public enum ScenarioCategory: String, CaseIterable, Sendable {
    case budget = "Budget Crisis"
    case technical = "Technical Challenge"
    case marketing = "Marketing Crisis"
    case hr = "HR Issue"
    case opportunity = "Market Opportunity"
    case ethical = "Ethical Dilemma"
    case competitive = "Competitive Threat"
    case innovation = "Innovation"
    case regulatory = "Regulatory"
}

public enum RiskLevel: String, CaseIterable, Sendable {
    case low = "Low Risk"
    case medium = "Medium Risk"
    case high = "High Risk"

    public var defaultVariance: Double {
        switch self {
        case .low: return GameConstants.lowVariance
        case .medium: return GameConstants.mediumVariance
        case .high: return GameConstants.highVariance
        }
    }

    public var icon: String {
        switch self {
        case .low: return "shield.checkmark"
        case .medium: return "exclamationmark.triangle"
        case .high: return "flame"
        }
    }
}

public enum ImpactDirection: String, Sendable {
    case positive = "Positive"
    case negative = "Negative"
    case neutral = "Neutral"
}

public struct ImpactHint: Equatable, Sendable {
    public let metric: String
    public let direction: ImpactDirection
    public let description: String

    public init(metric: String, direction: ImpactDirection, description: String) {
        self.metric = metric
        self.direction = direction
        self.description = description
    }

    public static func fromImpact(_ impact: DecisionImpact) -> [ImpactHint] {
        var hints: [ImpactHint] = []
        if impact.performanceChange > 0 {
            hints.append(ImpactHint(metric: "Performance", direction: .positive, description: "Likely boosts performance"))
        } else if impact.performanceChange < 0 {
            hints.append(ImpactHint(metric: "Performance", direction: .negative, description: "May hurt performance"))
        }
        if impact.moraleChange > 0 {
            hints.append(ImpactHint(metric: "Morale", direction: .positive, description: "Likely improves morale"))
        } else if impact.moraleChange < 0 {
            hints.append(ImpactHint(metric: "Morale", direction: .negative, description: "May lower morale"))
        }
        if impact.reputationChange > 0 {
            hints.append(ImpactHint(metric: "Reputation", direction: .positive, description: "Likely boosts reputation"))
        } else if impact.reputationChange < 0 {
            hints.append(ImpactHint(metric: "Reputation", direction: .negative, description: "May damage reputation"))
        }
        return hints
    }
}

public enum DifficultyPhase: String, CaseIterable, Sendable {
    case startup = "Startup"
    case growth = "Growth"
    case enterprise = "Enterprise"

    public static func forQuarter(_ quarter: Int) -> DifficultyPhase {
        if quarter <= 4 { return .startup }
        else if quarter <= 8 { return .growth }
        else { return .enterprise }
    }

    public var impactMultiplier: Double {
        switch self {
        case .startup: return GameConstants.startupImpactMultiplier
        case .growth: return GameConstants.growthImpactMultiplier
        case .enterprise: return GameConstants.enterpriseImpactMultiplier
        }
    }

    public var costMultiplier: Double {
        switch self {
        case .startup: return GameConstants.startupCostMultiplier
        case .growth: return GameConstants.growthCostMultiplier
        case .enterprise: return GameConstants.enterpriseCostMultiplier
        }
    }

    public var varianceMultiplier: Double {
        switch self {
        case .startup: return GameConstants.startupVarianceMultiplier
        case .growth: return GameConstants.growthVarianceMultiplier
        case .enterprise: return GameConstants.enterpriseVarianceMultiplier
        }
    }
}

public struct DecisionOption: Equatable, Sendable {
    public let title: String
    public let description: String
    public let cost: Double
    public let impact: DecisionImpact
    public let riskLevel: RiskLevel
    public let impactVariance: Double

    public init(title: String, description: String, cost: Double, impact: DecisionImpact, riskLevel: RiskLevel = .medium, impactVariance: Double = 0.2) {
        self.title = title
        self.description = description
        self.cost = cost
        self.impact = impact
        self.riskLevel = riskLevel
        self.impactVariance = impactVariance
    }
}

public struct DecisionImpact: Equatable, Sendable {
    public let performanceChange: Double
    public let moraleChange: Double
    public let budgetChange: Double
    public let reputationChange: Double
    public let departmentSpecific: DepartmentType?

    public init(
        performanceChange: Double = 0,
        moraleChange: Double = 0,
        budgetChange: Double = 0,
        reputationChange: Double = 0,
        departmentSpecific: DepartmentType? = nil
    ) {
        self.performanceChange = performanceChange
        self.moraleChange = moraleChange
        self.budgetChange = budgetChange
        self.reputationChange = reputationChange
        self.departmentSpecific = departmentSpecific
    }
}

public struct Scenario: Equatable, Sendable {
    public static func == (lhs: Scenario, rhs: Scenario) -> Bool {
        lhs.id == rhs.id
    }

    public let id: UUID
    public let category: ScenarioCategory
    public let title: String
    public let description: String
    public let options: [DecisionOption]
    public let quarter: Int

    public init(
        category: ScenarioCategory,
        title: String,
        description: String,
        options: [DecisionOption],
        quarter: Int
    ) {
        self.id = UUID()
        self.category = category
        self.title = title
        self.description = description
        self.options = options
        self.quarter = quarter
    }
}
