import XCTest
@testable import CEOSimulationCore

@MainActor
final class DepartmentAgentsTests: XCTestCase {
    var agentManager: AgentManager!
    var company: Company!

    override func setUp() {
        super.setUp()
        agentManager = AgentManager()
        company = Company()
    }

    override func tearDown() {
        agentManager = nil
        company = nil
        super.tearDown()
    }

    func testAllAgentsPresent() {
        XCTAssertEqual(agentManager.agents.count, 5)
        let departments = Set(agentManager.agents.map(\.department))
        XCTAssertEqual(departments, Set(DepartmentType.allCases))
    }

    func testSalesAgentBudgetResponse() {
        let scenario = Scenario(
            category: .budget,
            title: "Budget Test",
            description: "A budget scenario",
            options: [
                DecisionOption(title: "Option 1", description: "Desc", cost: 0, impact: DecisionImpact()),
                DecisionOption(title: "Option 2", description: "Desc", cost: 0, impact: DecisionImpact()),
            ],
            quarter: 1
        )
        let response = agentManager.getAgentResponse(for: .sales, scenario: scenario, company: company)
        XCTAssertFalse(response.message.isEmpty)
        XCTAssertNotNil(response.recommendedOption)
    }

    func testMarketingAgentOpportunityResponse() {
        let scenario = Scenario(
            category: .opportunity,
            title: "Opportunity Test",
            description: "An opportunity",
            options: [
                DecisionOption(title: "Option 1", description: "Desc", cost: 0, impact: DecisionImpact()),
            ],
            quarter: 1
        )
        let response = agentManager.getAgentResponse(for: .marketing, scenario: scenario, company: company)
        XCTAssertFalse(response.message.isEmpty)
        XCTAssertEqual(response.mood, .excited)
    }

    func testEngineeringAgentTechnicalResponse() {
        let scenario = Scenario(
            category: .technical,
            title: "Tech Challenge",
            description: "A technical issue",
            options: [
                DecisionOption(title: "Option 1", description: "Desc", cost: 0, impact: DecisionImpact()),
                DecisionOption(title: "Option 2", description: "Desc", cost: 0, impact: DecisionImpact()),
            ],
            quarter: 1
        )
        let response = agentManager.getAgentResponse(for: .engineering, scenario: scenario, company: company)
        XCTAssertFalse(response.message.isEmpty)
    }

    func testHRAgentHRResponse() {
        let scenario = Scenario(
            category: .hr,
            title: "HR Issue",
            description: "An HR matter",
            options: [
                DecisionOption(title: "Option 1", description: "Desc", cost: 0, impact: DecisionImpact()),
            ],
            quarter: 1
        )
        let response = agentManager.getAgentResponse(for: .hr, scenario: scenario, company: company)
        XCTAssertFalse(response.message.isEmpty)
        XCTAssertEqual(response.recommendedOption, 0)
    }

    func testFinanceAgentBudgetResponse() {
        let scenario = Scenario(
            category: .budget,
            title: "Financial Decision",
            description: "A budget decision",
            options: [
                DecisionOption(title: "Option 1", description: "Desc", cost: 0, impact: DecisionImpact()),
                DecisionOption(title: "Option 2", description: "Desc", cost: 0, impact: DecisionImpact()),
                DecisionOption(title: "Option 3", description: "Desc", cost: 0, impact: DecisionImpact()),
            ],
            quarter: 1
        )
        let response = agentManager.getAgentResponse(for: .finance, scenario: scenario, company: company)
        XCTAssertFalse(response.message.isEmpty)
    }

    func testFinanceAgentOpportunityMoodIsCautious() {
        let scenario = Scenario(
            category: .opportunity,
            title: "Opportunity Test",
            description: "An opportunity",
            options: [
                DecisionOption(title: "Option 1", description: "Desc", cost: 0, impact: DecisionImpact()),
            ],
            quarter: 1
        )
        let response = agentManager.getAgentResponse(for: .finance, scenario: scenario, company: company)
        XCTAssertEqual(response.mood, .cautious)
    }

    func testSalesQuarterlyReportHighPerformance() {
        company.departments.first { $0.type == .sales }!.performance = 85
        let reports = agentManager.getQuarterlyReports(for: company)
        let salesReport = reports[.sales]!
        XCTAssertTrue(salesReport.contains("Outstanding"))
    }

    func testSalesQuarterlyReportLowPerformance() {
        company.departments.first { $0.type == .sales }!.performance = 30
        let reports = agentManager.getQuarterlyReports(for: company)
        let salesReport = reports[.sales]!
        XCTAssertTrue(salesReport.contains("Challenging"))
    }

    func testReactToDecisionPositiveImpact() {
        let decision = DecisionOption(
            title: "Good Decision",
            description: "Positive",
            cost: 5000,
            impact: DecisionImpact(reputationChange: 10)
        )
        let reactions = agentManager.getDecisionReactions(decision, impact: decision.impact)
        XCTAssertEqual(reactions.count, 5)
        // Sales should be happy about reputation boost
        XCTAssertTrue(reactions[.sales]!.contains("trust") || reactions[.sales]!.contains("Great"))
    }

    func testReactToDecisionNegativeImpact() {
        let decision = DecisionOption(
            title: "Costly Decision",
            description: "Expensive",
            cost: 30000,
            impact: DecisionImpact(performanceChange: -10, budgetChange: -30000)
        )
        let reactions = agentManager.getDecisionReactions(decision, impact: decision.impact)
        XCTAssertEqual(reactions.count, 5)
    }

    func testGetAllAgentResponses() {
        let scenario = Scenario(
            category: .technical,
            title: "Test",
            description: "Test scenario",
            options: [
                DecisionOption(title: "A", description: "a", cost: 0, impact: DecisionImpact()),
            ],
            quarter: 1
        )
        let responses = agentManager.getAllAgentResponses(for: scenario, company: company)
        XCTAssertEqual(responses.count, 5)
    }

    func testGetQuarterlyReports() {
        let reports = agentManager.getQuarterlyReports(for: company)
        XCTAssertEqual(reports.count, 5)
        for dept in DepartmentType.allCases {
            XCTAssertNotNil(reports[dept])
            XCTAssertFalse(reports[dept]!.isEmpty)
        }
    }
}
