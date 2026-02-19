import Foundation

/// A point-in-time capture of key company metrics taken at the end of each quarter,
/// used to power trend charts in the quarterly report.
public struct QuarterSnapshot: Sendable, Identifiable {
    /// The quarter number (1–12) that just completed.
    public let quarter: Int
    /// Company-level budget at quarter end.
    public let budget: Double
    /// Each department's performance % at quarter end.
    public let departmentPerformance: [DepartmentType: Double]

    public var id: Int { quarter }

    public init(quarter: Int, budget: Double, departmentPerformance: [DepartmentType: Double]) {
        self.quarter = quarter
        self.budget = budget
        self.departmentPerformance = departmentPerformance
    }
}
