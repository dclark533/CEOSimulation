import Foundation

@MainActor
public class SalesAgent: AIAgent {
    public let department: DepartmentType = .sales
    public let personality: AgentPersonality
    
    public init() {
        self.personality = AgentPersonality(
            traits: ["results-oriented", "competitive", "optimistic"],
            communicationStyle: .enthusiastic,
            riskTolerance: .moderate
        )
    }
    
    public func generateResponse(to scenario: Scenario, companyState: Company) -> AgentResponse {
        guard let salesDept = companyState.departments.first(where: { $0.type == .sales }) else {
            return AgentResponse(message: "Sales data unavailable.", recommendedOption: 1, reasoning: "Department not found.", mood: .neutral)
        }

        switch scenario.category {
        case .budget:
            return AgentResponse(
                message: "We can't let budget constraints kill our momentum! Sales are looking strong, and with the right investment, we can hit our targets.",
                recommendedOption: salesDept.performance > 60 ? 1 : 0,
                reasoning: "Sales performance is \(Int(salesDept.performance))%, so we need to balance investment with caution.",
                mood: salesDept.performance > 50 ? .excited : .concerned
            )
        case .marketing:
            return AgentResponse(
                message: "Marketing challenges directly impact our pipeline. We need to act fast to protect our customer relationships!",
                recommendedOption: 0,
                reasoning: "Quick action protects sales opportunities and maintains client trust.",
                mood: .concerned
            )
        case .opportunity:
            return AgentResponse(
                message: "This is exactly the kind of opportunity that drives revenue growth! Let's be bold and capture market share.",
                recommendedOption: 0,
                reasoning: "Sales sees the revenue potential and wants to maximize market capture.",
                mood: .excited
            )
        default:
            return AgentResponse(
                message: "How does this impact our sales targets and customer relationships?",
                recommendedOption: 1,
                reasoning: "Looking for balanced approach that protects sales performance.",
                mood: .neutral
            )
        }
    }
    
    public func provideQuarterlyReport(for company: Company) -> String {
        guard let salesDept = company.departments.first(where: { $0.type == .sales }) else { return "Sales data unavailable." }
        let performance = Int(salesDept.performance)
        
        if performance >= 80 {
            return "🎯 Outstanding quarter! Sales exceeded targets by crushing our competitive positioning. The team's energy is infectious!"
        } else if performance >= 60 {
            return "📈 Solid performance this quarter. We're tracking well toward our annual goals, though there's room to push harder."
        } else if performance >= 40 {
            return "📊 Mixed results this quarter. Some wins, but we need to address pipeline gaps and conversion rates."
        } else {
            return "⚠️ Challenging quarter. We need immediate action on lead generation and deal closure strategies."
        }
    }
    
    public func reactToDecision(_ decision: DecisionOption, impact: DecisionImpact) -> String {
        if impact.reputationChange > 5 {
            return "Great choice! This will definitely help with customer trust and new client acquisition."
        } else if impact.budgetChange < -20000 {
            return "That's a significant investment. I hope we can show strong ROI to justify this to prospects."
        } else if impact.performanceChange < -5 {
            return "I'm concerned about how this might affect our sales metrics and team morale."
        } else {
            return "Understood. Let's make sure we communicate any changes effectively to our clients."
        }
    }
}

@MainActor
public class MarketingAgent: AIAgent {
    public let department: DepartmentType = .marketing
    public let personality: AgentPersonality
    
    public init() {
        self.personality = AgentPersonality(
            traits: ["creative", "brand-focused", "strategic"],
            communicationStyle: .diplomatic,
            riskTolerance: .moderate
        )
    }
    
    public func generateResponse(to scenario: Scenario, companyState: Company) -> AgentResponse {
        guard let marketingDept = companyState.departments.first(where: { $0.type == .marketing }) else {
            return AgentResponse(message: "Marketing data unavailable.", recommendedOption: 1, reasoning: "Department not found.", mood: .neutral)
        }
        
        switch scenario.category {
        case .marketing:
            return AgentResponse(
                message: "Brand reputation is everything in education. We need a comprehensive response that shows we care about our community and take feedback seriously.",
                recommendedOption: 0,
                reasoning: "Strong marketing response protects long-term brand value and demonstrates responsiveness to community concerns.",
                mood: .concerned
            )
        case .opportunity:
            return AgentResponse(
                message: "This could be a game-changer for our brand positioning! We should leverage this opportunity to showcase our innovation and commitment to education excellence.",
                recommendedOption: marketingDept.performance > 60 ? 0 : 1,
                reasoning: "Marketing sees the brand-building potential, but recommends approach based on current campaign capacity.",
                mood: .excited
            )
        case .technical:
            return AgentResponse(
                message: "How we handle technical challenges affects customer confidence. We should communicate proactively and position any improvements as investments in user experience.",
                recommendedOption: 1,
                reasoning: "Marketing wants to balance technical needs with brand messaging opportunities.",
                mood: .neutral
            )
        default:
            return AgentResponse(
                message: "Let's think about the brand implications and how we communicate this to our stakeholders and community.",
                recommendedOption: 1,
                reasoning: "Marketing focuses on communication strategy and brand impact.",
                mood: .neutral
            )
        }
    }
    
    public func provideQuarterlyReport(for company: Company) -> String {
        guard let marketingDept = company.departments.first(where: { $0.type == .marketing }) else { return "Marketing data unavailable." }
        let performance = Int(marketingDept.performance)
        
        if performance >= 80 {
            return "🚀 Exceptional brand momentum! Our campaigns are resonating beautifully with educators and learners. Brand sentiment is at an all-time high."
        } else if performance >= 60 {
            return "📢 Strong marketing quarter with solid engagement across channels. Brand awareness is growing steadily in key segments."
        } else if performance >= 40 {
            return "🎨 Creative campaigns launched but results are mixed. We need to refine our messaging and channel strategy."
        } else {
            return "📱 Marketing efforts need serious optimization. Brand visibility and engagement metrics are concerning."
        }
    }
    
    public func reactToDecision(_ decision: DecisionOption, impact: DecisionImpact) -> String {
        if impact.reputationChange > 5 {
            return "Perfect! This aligns beautifully with our brand values and will resonate well with our education community."
        } else if impact.reputationChange < -3 {
            return "We'll need to craft careful messaging around this decision to minimize any negative brand impact."
        } else if decision.cost > 15000 {
            return "That's a substantial marketing investment. Let's make sure we maximize the brand-building potential."
        } else {
            return "I can work with this direction. We'll incorporate it into our ongoing brand narrative."
        }
    }
}

@MainActor
public class EngineeringAgent: AIAgent {
    public let department: DepartmentType = .engineering
    public let personality: AgentPersonality
    
    public init() {
        self.personality = AgentPersonality(
            traits: ["technical", "perfectionist", "innovative"],
            communicationStyle: .analytical,
            riskTolerance: .conservative
        )
    }
    
    public func generateResponse(to scenario: Scenario, companyState: Company) -> AgentResponse {
        guard let engineeringDept = companyState.departments.first(where: { $0.type == .engineering }) else {
            return AgentResponse(message: "Engineering data unavailable.", recommendedOption: 1, reasoning: "Department not found.", mood: .neutral)
        }
        
        switch scenario.category {
        case .technical:
            return AgentResponse(
                message: "Technical debt and infrastructure challenges need proper solutions, not quick fixes. Let's implement this correctly the first time.",
                recommendedOption: engineeringDept.performance > 60 ? 0 : 1,
                reasoning: "Engineering prioritizes long-term stability and proper implementation over short-term savings.",
                mood: engineeringDept.performance > 50 ? .neutral : .worried
            )
        case .budget:
            return AgentResponse(
                message: "Budget cuts often mean cutting corners on quality and security. We need to be strategic about what we can deliver with reduced resources.",
                recommendedOption: 2,
                reasoning: "Engineering wants to maintain quality standards while being fiscally responsible.",
                mood: .concerned
            )
        case .opportunity:
            if scenario.title.contains("AI") {
                return AgentResponse(
                    message: "AI integration is complex but transformative. We have the technical expertise, but need adequate resources for proper implementation.",
                    recommendedOption: 1,
                    reasoning: "Engineering sees the technical potential but wants realistic timelines and budgets.",
                    mood: .excited
                )
            } else {
                return AgentResponse(
                    message: "Any new initiative needs proper technical architecture planning. Let's ensure we can deliver quality solutions.",
                    recommendedOption: 1,
                    reasoning: "Engineering emphasizes technical feasibility and quality implementation.",
                    mood: .neutral
                )
            }
        default:
            return AgentResponse(
                message: "What are the technical requirements and constraints for this decision?",
                recommendedOption: 1,
                reasoning: "Engineering always considers technical implications first.",
                mood: .neutral
            )
        }
    }
    
    public func provideQuarterlyReport(for company: Company) -> String {
        guard let engineeringDept = company.departments.first(where: { $0.type == .engineering }) else { return "Engineering data unavailable." }
        let performance = Int(engineeringDept.performance)
        
        if performance >= 80 {
            return "⚡ Excellent technical execution this quarter. System reliability is strong, and we're shipping quality features on schedule."
        } else if performance >= 60 {
            return "🔧 Solid engineering progress with good system stability. A few technical challenges but overall positive trajectory."
        } else if performance >= 40 {
            return "⚙️ Engineering metrics show room for improvement. Some technical debt accumulation and delivery delays."
        } else {
            return "🚨 Significant technical challenges this quarter. System stability and feature delivery are both concerning."
        }
    }
    
    public func reactToDecision(_ decision: DecisionOption, impact: DecisionImpact) -> String {
        if decision.title.contains("upgrade") || decision.title.contains("investment") {
            return "Good technical decision. This investment in our infrastructure will pay dividends in system reliability."
        } else if impact.budgetChange < -25000 {
            return "That's a substantial budget allocation. I hope we have adequate resources for proper implementation."
        } else if decision.title.contains("patch") || decision.title.contains("delay") {
            return "I'm concerned about the technical implications of taking shortcuts. This could create future problems."
        } else {
            return "I'll need to assess the technical requirements and implementation timeline for this decision."
        }
    }
}

@MainActor
public class HRAgent: AIAgent {
    public let department: DepartmentType = .hr
    public let personality: AgentPersonality
    
    public init() {
        self.personality = AgentPersonality(
            traits: ["empathetic", "people-focused", "collaborative"],
            communicationStyle: .diplomatic,
            riskTolerance: .conservative
        )
    }
    
    public func generateResponse(to scenario: Scenario, companyState: Company) -> AgentResponse {
        guard let hrDept = companyState.departments.first(where: { $0.type == .hr }) else {
            return AgentResponse(message: "HR data unavailable.", recommendedOption: 1, reasoning: "Department not found.", mood: .neutral)
        }
        
        switch scenario.category {
        case .hr:
            return AgentResponse(
                message: "Our people are our greatest asset. Investing in employee satisfaction and well-being always pays off in productivity and retention.",
                recommendedOption: 0,
                reasoning: "HR prioritizes employee welfare and long-term team stability over short-term cost savings.",
                mood: hrDept.morale > 60 ? .happy : .concerned
            )
        case .budget:
            return AgentResponse(
                message: "Budget pressures shouldn't compromise our commitment to our team. Let's find solutions that protect employee welfare while being fiscally responsible.",
                recommendedOption: 1,
                reasoning: "HR seeks balance between financial constraints and employee needs.",
                mood: .worried
            )
        case .opportunity:
            return AgentResponse(
                message: "Growth opportunities are exciting, but we need to ensure we have the right people and culture to support expansion successfully.",
                recommendedOption: 1,
                reasoning: "HR considers human resource capacity and cultural impact of growth decisions.",
                mood: .neutral
            )
        default:
            return AgentResponse(
                message: "How will this decision affect our team's morale, workload, and overall well-being?",
                recommendedOption: 1,
                reasoning: "HR always considers people impact in all business decisions.",
                mood: .neutral
            )
        }
    }
    
    public func provideQuarterlyReport(for company: Company) -> String {
        guard let hrDept = company.departments.first(where: { $0.type == .hr }) else { return "HR data unavailable." }
        let morale = Int(hrDept.morale)
        
        if morale >= 80 {
            return "🌟 Team morale is excellent! Employee engagement is high, and we're seeing great collaboration across departments."
        } else if morale >= 60 {
            return "👥 Positive team dynamics this quarter. Employee satisfaction is good with minor areas for improvement."
        } else if morale >= 40 {
            return "🤝 Mixed signals from the team. Some departments are thriving while others need attention and support."
        } else {
            return "😟 Team morale needs immediate attention. Employee satisfaction is low and turnover risk is high."
        }
    }
    
    public func reactToDecision(_ decision: DecisionOption, impact: DecisionImpact) -> String {
        if impact.moraleChange > 5 {
            return "Wonderful! This decision shows we truly value our people and will boost team morale significantly."
        } else if impact.moraleChange < -5 {
            return "I'm concerned about the impact on team morale. We'll need to communicate carefully and provide extra support."
        } else if decision.title.contains("culture") || decision.title.contains("retention") {
            return "I appreciate the focus on our people. This kind of investment in human capital always pays off."
        } else {
            return "I'll monitor how this affects our team and be ready to provide additional support if needed."
        }
    }
}

@MainActor
public class FinanceAgent: AIAgent {
    public let department: DepartmentType = .finance
    public let personality: AgentPersonality
    
    public init() {
        self.personality = AgentPersonality(
            traits: ["analytical", "cautious", "detail-oriented"],
            communicationStyle: .direct,
            riskTolerance: .conservative
        )
    }
    
    public func generateResponse(to scenario: Scenario, companyState: Company) -> AgentResponse {
        switch scenario.category {
        case .budget:
            return AgentResponse(
                message: "Financial discipline is crucial for long-term sustainability. We need to make data-driven decisions that protect our cash flow and maintain healthy margins.",
                recommendedOption: companyState.budget > 75000 ? 1 : 2,
                reasoning: "Finance recommends conservative approach based on current budget position of $\(Int(companyState.budget)).",
                mood: companyState.budget > 50000 ? .neutral : .worried
            )
        case .opportunity:
            return AgentResponse(
                message: "ROI analysis is essential before any major investment. Let's ensure the projected returns justify the financial risk and timeline.",
                recommendedOption: 1,
                reasoning: "Finance prefers measured approach with clear financial metrics and risk assessment.",
                mood: .cautious
            )
        default:
            return AgentResponse(
                message: "What's the expected ROI and payback period? We need to ensure this investment aligns with our financial objectives and cash flow projections.",
                recommendedOption: 1,
                reasoning: "Finance evaluates all decisions through financial impact and return metrics.",
                mood: .neutral
            )
        }
    }
    
    public func provideQuarterlyReport(for company: Company) -> String {
        let budget = Int(company.budget)
        
        if budget >= 100000 {
            return "💰 Strong financial position with healthy cash flow. We're well-positioned for strategic investments and growth initiatives."
        } else if budget >= 50000 {
            return "📊 Stable financial metrics with adequate reserves. Cash flow management is on track with moderate growth potential."
        } else if budget >= 25000 {
            return "⚖️ Tight budget management required. We need to prioritize essential expenses and monitor cash flow closely."
        } else {
            return "🚨 Critical financial situation. Immediate cash flow improvement and expense reduction are essential for survival."
        }
    }
    
    public func reactToDecision(_ decision: DecisionOption, impact: DecisionImpact) -> String {
        if impact.budgetChange > 10000 {
            return "Excellent! This positive cash flow impact strengthens our financial position and provides more strategic flexibility."
        } else if impact.budgetChange < -25000 {
            return "That's a significant financial commitment. I hope we've thoroughly analyzed the ROI and have contingency plans."
        } else if impact.budgetChange < -10000 {
            return "Noted. I'll track this expense carefully and ensure it delivers the expected value within our financial projections."
        } else {
            return "Acceptable financial impact. This fits within our budget parameters and risk tolerance."
        }
    }
}

@MainActor
public class AgentManager {
    public let agents: [AIAgent]
    
    public init() {
        self.agents = [
            SalesAgent(),
            MarketingAgent(),
            EngineeringAgent(),
            HRAgent(),
            FinanceAgent()
        ]
    }
    
    public func getAgentResponse(for department: DepartmentType, scenario: Scenario, company: Company) -> AgentResponse {
        guard let agent = agents.first(where: { $0.department == department }) else {
            return AgentResponse(
                message: "No input from this department.",
                recommendedOption: nil,
                reasoning: "Agent not available.",
                mood: .neutral
            )
        }
        
        return agent.generateResponse(to: scenario, companyState: company)
    }
    
    public func getAllAgentResponses(for scenario: Scenario, company: Company) -> [DepartmentType: AgentResponse] {
        var responses: [DepartmentType: AgentResponse] = [:]
        
        for agent in agents {
            responses[agent.department] = agent.generateResponse(to: scenario, companyState: company)
        }
        
        return responses
    }
    
    public func getQuarterlyReports(for company: Company) -> [DepartmentType: String] {
        var reports: [DepartmentType: String] = [:]
        
        for agent in agents {
            reports[agent.department] = agent.provideQuarterlyReport(for: company)
        }
        
        return reports
    }
    
    public func getDecisionReactions(_ decision: DecisionOption, impact: DecisionImpact) -> [DepartmentType: String] {
        var reactions: [DepartmentType: String] = [:]
        
        for agent in agents {
            reactions[agent.department] = agent.reactToDecision(decision, impact: impact)
        }
        
        return reactions
    }
}