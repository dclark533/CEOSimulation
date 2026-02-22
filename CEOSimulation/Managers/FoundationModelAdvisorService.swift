import Foundation
import FoundationModels
import CEOSimulationCore

@available(iOS 26.0, macOS 26.0, *)
@MainActor
class FoundationModelAdvisorService {

    // MARK: - Structured Output

    @Generable
    struct AdvisorOutput {
        @Guide(description: "1-2 sentence advice from your perspective as this department head")
        var message: String

        @Guide(description: "Index of your preferred option: 0, 1, or 2")
        var recommendedOption: Int

        @Guide(description: "One sentence explaining your recommendation")
        var reasoning: String

        @Guide(description: "Your current mood: happy, neutral, concerned, frustrated, excited, worried, or cautious")
        var mood: String
    }

    // MARK: - State

    private var sessions: [DepartmentType: LanguageModelSession] = [:]
    private(set) var isAvailable = false

    // MARK: - Init

    init() {
        if case .available = SystemLanguageModel.default.availability {
            isAvailable = true
            initializeSessions()
        }
    }

    // MARK: - Session Lifecycle

    private func initializeSessions() {
        for department in DepartmentType.allCases {
            sessions[department] = LanguageModelSession(
                instructions: systemPrompt(for: department)
            )
        }
    }

    func resetSessions() {
        sessions.removeAll()
        if case .available = SystemLanguageModel.default.availability {
            isAvailable = true
            initializeSessions()
        } else {
            isAvailable = false
        }
    }

    // MARK: - Generation

    func generateAdvisorResponse(agent: any AIAgent, scenario: Scenario, company: Company) async -> AgentResponse {
        guard isAvailable, let session = sessions[agent.department] else {
            return agent.generateResponse(to: scenario, companyState: company)
        }

        let prompt = scenarioPrompt(for: scenario, company: company, agent: agent)

        do {
            let response = try await session.respond(to: prompt, generating: AdvisorOutput.self)
            let output = response.content
            let clampedIndex = max(0, min(scenario.options.count - 1, output.recommendedOption))
            return AgentResponse(
                message: output.message,
                recommendedOption: scenario.options.isEmpty ? nil : clampedIndex,
                reasoning: output.reasoning,
                mood: agentMood(from: output.mood)
            )
        } catch {
            return agent.generateResponse(to: scenario, companyState: company)
        }
    }

    func generateQuarterlyReport(agent: any AIAgent, company: Company) async -> String {
        guard isAvailable, let session = sessions[agent.department] else {
            return agent.provideQuarterlyReport(for: company)
        }

        let dept = company.departments.first(where: { $0.type == agent.department })
        let performance = dept.map { Int($0.performance) } ?? 0
        let morale = dept.map { Int($0.morale) } ?? 0

        let prompt = """
        Quarter \(company.quarter)/12. Department performance: \(performance)%. \
        Morale: \(morale)%. Company budget: $\(Int(company.budget / 1000))k. \
        Reputation: \(Int(company.reputation))%.

        Provide a brief quarterly department summary from your perspective as department head. 2-3 sentences, staying in character.
        """

        do {
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            return agent.provideQuarterlyReport(for: company)
        }
    }

    // MARK: - System Prompts

    private func systemPrompt(for department: DepartmentType) -> String {
        switch department {
        case .sales:
            return """
            You are Alex Rivera, VP of Sales at a tech company.
            Personality: results-oriented, competitive, optimistic. Communication style: enthusiastic. Risk tolerance: moderate.
            Keep responses concise and in-character.
            """
        case .marketing:
            return """
            You are Jordan Chen, VP of Marketing at a tech company.
            Personality: creative, brand-focused, strategic. Communication style: diplomatic. Risk tolerance: moderate.
            Keep responses concise and in-character.
            """
        case .engineering:
            return """
            You are Sam Park, VP of Engineering at a tech company.
            Personality: technical, perfectionist, innovative. Communication style: analytical. Risk tolerance: conservative.
            Keep responses concise and in-character.
            """
        case .hr:
            return """
            You are Morgan Taylor, VP of Human Resources at a tech company.
            Personality: empathetic, people-focused, collaborative. Communication style: diplomatic. Risk tolerance: conservative.
            Keep responses concise and in-character.
            """
        case .finance:
            return """
            You are Casey Williams, VP of Finance at a tech company.
            Personality: analytical, cautious, detail-oriented. Communication style: direct. Risk tolerance: conservative.
            Keep responses concise and in-character.
            """
        }
    }

    // MARK: - User Prompts

    private func scenarioPrompt(for scenario: Scenario, company: Company, agent: any AIAgent) -> String {
        let dept = company.departments.first(where: { $0.type == agent.department })
        let performance = dept.map { Int($0.performance) } ?? 0
        let morale = dept.map { Int($0.morale) } ?? 0

        let optionsText = scenario.options.enumerated().map { index, option in
            "\(index). \(option.title): \(option.description) (Cost: $\(Int(option.cost / 1000))k)"
        }.joined(separator: "\n")

        return """
        Quarter \(scenario.quarter)/12. Department performance: \(performance)%. \
        Morale: \(morale)%. Company budget: $\(Int(company.budget / 1000))k. \
        Reputation: \(Int(company.reputation))%.

        Scenario: \(scenario.title) — \(scenario.description)

        Options:
        \(optionsText)

        Respond as this advisor.
        """
    }

    // MARK: - Helpers

    private func agentMood(from moodString: String) -> AgentMood {
        switch moodString.lowercased() {
        case "happy":     return .happy
        case "concerned": return .concerned
        case "frustrated": return .frustrated
        case "excited":   return .excited
        case "worried":   return .worried
        case "cautious":  return .cautious
        default:          return .neutral
        }
    }
}
