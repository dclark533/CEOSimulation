import Foundation

@MainActor
@Observable
public class Company {
    public var budget: Double
    public var reputation: Double
    public var overallPerformance: Double
    public var quarter: Int
    public var departments: [Department]
    
    public init(
        budget: Double = GameConstants.initialBudget,
        reputation: Double = GameConstants.initialReputation,
        overallPerformance: Double = GameConstants.initialPerformance,
        quarter: Int = 1
    ) {
        self.budget = budget
        self.reputation = reputation
        self.overallPerformance = overallPerformance
        self.quarter = quarter
        self.departments = [
            Department(type: .sales),
            Department(type: .marketing),
            Department(type: .engineering),
            Department(type: .hr),
            Department(type: .finance)
        ]
    }
    
    public func updateMetrics() {
        overallPerformance = departments.map(\.performance).reduce(0, +) / Double(departments.count)
    }
    
    public func advanceQuarter() {
        quarter += 1
        for department in departments {
            department.generateQuarterlyReport()
        }
    }
}