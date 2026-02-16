import Foundation

public enum ScenarioCategory: String, CaseIterable, Sendable {
    case budget = "Budget Crisis"
    case technical = "Technical Challenge" 
    case marketing = "Marketing Crisis"
    case hr = "HR Issue"
    case opportunity = "Market Opportunity"
}

public struct DecisionOption: Equatable, Sendable {
    public let title: String
    public let description: String
    public let cost: Double
    public let impact: DecisionImpact
    
    public init(title: String, description: String, cost: Double, impact: DecisionImpact) {
        self.title = title
        self.description = description
        self.cost = cost
        self.impact = impact
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