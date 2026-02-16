import SwiftUI
import CEOSimulationCore

struct GameView: View {
    let gameController: GameController
    let agentManager: AgentManager
    @Binding var showingQuarterlyReport: Bool
    @State private var selectedTab: GameTab = .scenario
    @State private var showingAgentAdvice = false
    @State private var agentResponses: [DepartmentType: AgentResponse] = [:]
    
    enum GameTab: String, CaseIterable {
        case scenario = "Scenario"
        case advisors = "Advisors"
        case metrics = "Metrics"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                ScenarioView(
                    gameController: gameController,
                    agentResponses: $agentResponses,
                    showingAgentAdvice: $showingAgentAdvice
                )
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("Scenario")
                }
                .tag(GameTab.scenario)
                
                AdvisorsView(
                    agentManager: agentManager,
                    gameController: gameController,
                    agentResponses: agentResponses
                )
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Advisors")
                }
                .tag(GameTab.advisors)
                
                MetricsView(gameController: gameController)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Metrics")
                }
                .tag(GameTab.metrics)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Pause Game") {
                            gameController.pauseGame()
                        }
                        
                        Divider()
                        
                        Button("Exit Game", role: .destructive) {
                            gameController.requestExitGame()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .onChange(of: gameController.currentScenario) { oldValue, newValue in
            if let scenario = newValue {
                loadAgentResponses(for: scenario)
            }
        }
        .onChange(of: gameController.company.quarter) { oldValue, newValue in
            if newValue > oldValue && newValue % 4 == 1 {
                showingQuarterlyReport = true
            }
        }
    }
    
    private func loadAgentResponses(for scenario: Scenario) {
        agentResponses = agentManager.getAllAgentResponses(
            for: scenario,
            company: gameController.company
        )
    }
}

struct ScenarioView: View {
    let gameController: GameController
    @Binding var agentResponses: [DepartmentType: AgentResponse]
    @Binding var showingAgentAdvice: Bool
    @State private var selectedOptionIndex: Int?
    
    var body: some View {
        if let scenario = gameController.currentScenario {
            VStack(alignment: .leading, spacing: 20) {
                ScenarioHeaderView(scenario: scenario)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ScenarioDescriptionView(scenario: scenario)
                        
                        DecisionOptionsView(
                            scenario: scenario,
                            selectedOptionIndex: $selectedOptionIndex,
                            onDecisionMade: { optionIndex in
                                gameController.makeDecision(optionIndex)
                                selectedOptionIndex = nil
                            }
                        )
                        
                        if !agentResponses.isEmpty {
                            AgentAdvicePreviewView(
                                agentResponses: agentResponses,
                                showingAgentAdvice: $showingAgentAdvice
                            )
                        }
                    }
                    .padding()
                }
            }
        } else {
            VStack {
                ProgressView("Preparing next scenario...")
                    .scaleEffect(1.2)
                Text("Analyzing company performance and generating challenges...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct ScenarioHeaderView: View {
    let scenario: Scenario
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                CategoryBadge(category: scenario.category)
                Spacer()
                Text("Quarter \(scenario.quarter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(4)
            }
            
            Text(scenario.title)
                .font(.title)
                .fontWeight(.bold)
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

struct CategoryBadge: View {
    let category: ScenarioCategory
    
    var body: some View {
        Text(category.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(categoryColor.opacity(0.2))
            .foregroundColor(categoryColor)
            .cornerRadius(6)
    }
    
    private var categoryColor: Color {
        switch category {
        case .budget: return .red
        case .technical: return .blue
        case .marketing: return .purple
        case .hr: return .green
        case .opportunity: return .orange
        }
    }
}

struct ScenarioDescriptionView: View {
    let scenario: Scenario
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Situation")
                .font(.headline)
            
            Text(scenario.description)
                .font(.body)
                .lineSpacing(4)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

struct DecisionOptionsView: View {
    let scenario: Scenario
    @Binding var selectedOptionIndex: Int?
    let onDecisionMade: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Options")
                .font(.headline)
            
            ForEach(Array(scenario.options.enumerated()), id: \.offset) { index, option in
                DecisionOptionCard(
                    option: option,
                    index: index,
                    isSelected: selectedOptionIndex == index,
                    onTap: {
                        selectedOptionIndex = index
                    }
                )
            }
            
            if let selectedIndex = selectedOptionIndex {
                HStack {
                    Button("Cancel") {
                        selectedOptionIndex = nil
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Make Decision") {
                        onDecisionMade(selectedIndex)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top)
            }
        }
    }
}

struct DecisionOptionCard: View {
    let option: DecisionOption
    let index: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(option.title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                Text("$\(Int(option.cost).formatted())")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : costColor)
            }
            
            Text(option.description)
                .font(.body)
                .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
            
            ImpactPreviewView(
                impact: option.impact,
                isSelected: isSelected
            )
        }
        .padding()
        .background(isSelected ? Color.accentColor : Color(.systemGray6))
        .cornerRadius(12)
        .onTapGesture {
            onTap()
        }
    }
    
    private var costColor: Color {
        if option.cost == 0 {
            return .green
        } else if option.cost <= 10000 {
            return .orange
        } else {
            return .red
        }
    }
}

struct ImpactPreviewView: View {
    let impact: DecisionImpact
    let isSelected: Bool
    
    var body: some View {
        HStack {
            if impact.performanceChange != 0 {
                ImpactChip(
                    label: "Performance",
                    value: impact.performanceChange,
                    isSelected: isSelected
                )
            }
            
            if impact.moraleChange != 0 {
                ImpactChip(
                    label: "Morale",
                    value: impact.moraleChange,
                    isSelected: isSelected
                )
            }
            
            if impact.reputationChange != 0 {
                ImpactChip(
                    label: "Reputation",
                    value: impact.reputationChange,
                    isSelected: isSelected
                )
            }
            
            Spacer()
        }
    }
}

struct ImpactChip: View {
    let label: String
    let value: Double
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
            Text(value > 0 ? "+\(Int(value))" : "\(Int(value))")
                .fontWeight(.semibold)
        }
        .font(.caption)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(isSelected ? Color.white.opacity(0.2) : impactColor.opacity(0.2))
        .foregroundColor(isSelected ? .white : impactColor)
        .cornerRadius(4)
    }
    
    private var impactColor: Color {
        value > 0 ? .green : value < 0 ? .red : .gray
    }
}

struct AgentAdvicePreviewView: View {
    let agentResponses: [DepartmentType: AgentResponse]
    @Binding var showingAgentAdvice: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Department Advice")
                    .font(.headline)
                
                Spacer()
                
                Button("View All Advice") {
                    showingAgentAdvice = true
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(agentResponses.keys), id: \.self) { department in
                        if let response = agentResponses[department] {
                            AgentAdviceCard(
                                department: department,
                                response: response
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct AgentAdviceCard: View {
    let department: DepartmentType
    let response: AgentResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: department.icon)
                    .foregroundColor(.blue)
                Text(department.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(response.mood.rawValue)
                    .font(.caption)
            }
            
            Text(response.message)
                .font(.caption)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            if let recommendation = response.recommendedOption {
                Text("Recommends option \(recommendation + 1)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .padding(8)
        .frame(width: 200)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    GameView(
        gameController: GameController(),
        agentManager: AgentManager(),
        showingQuarterlyReport: .constant(false)
    )
}