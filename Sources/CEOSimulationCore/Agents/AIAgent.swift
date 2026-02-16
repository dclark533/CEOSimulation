import Foundation

@MainActor
public protocol AIAgent {
    var department: DepartmentType { get }
    var personality: AgentPersonality { get }
    
    func generateResponse(to scenario: Scenario, companyState: Company) -> AgentResponse
    func provideQuarterlyReport(for company: Company) -> String
    func reactToDecision(_ decision: DecisionOption, impact: DecisionImpact) -> String
}

public struct AgentPersonality: Sendable {
    public let traits: [String]
    public let communicationStyle: CommunicationStyle
    public let riskTolerance: RiskTolerance
    
    public init(traits: [String], communicationStyle: CommunicationStyle, riskTolerance: RiskTolerance) {
        self.traits = traits
        self.communicationStyle = communicationStyle
        self.riskTolerance = riskTolerance
    }
}

public enum CommunicationStyle: String, CaseIterable, Sendable {
    case analytical = "Analytical"
    case enthusiastic = "Enthusiastic" 
    case cautious = "Cautious"
    case direct = "Direct"
    case diplomatic = "Diplomatic"
}

public enum RiskTolerance: String, CaseIterable, Sendable {
    case conservative = "Conservative"
    case moderate = "Moderate"
    case aggressive = "Aggressive"
}

public struct AgentResponse: Sendable {
    public let message: String
    public let recommendedOption: Int?
    public let reasoning: String
    public let mood: AgentMood
    
    public init(message: String, recommendedOption: Int?, reasoning: String, mood: AgentMood) {
        self.message = message
        self.recommendedOption = recommendedOption
        self.reasoning = reasoning
        self.mood = mood
    }
}

public enum AgentMood: String, CaseIterable, Sendable {
    case happy = "😊"
    case neutral = "😐"
    case concerned = "😟"
    case frustrated = "😤"
    case excited = "🤩"
    case worried = "😰"
    case cautious = "🤔"
}