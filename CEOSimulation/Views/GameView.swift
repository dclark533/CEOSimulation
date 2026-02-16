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
                ToolbarItem(placement: .automatic) {
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
                // Market Event Banner
                if let event = gameController.currentMarketEvent {
                    MarketEventBanner(event: event)
                }

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

// MARK: - Market Event Banner

struct MarketEventBanner: View {
    let event: MarketEvent

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.icon)
                .font(.title3)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(event.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding()
        .background(Color.indigo.gradient)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// MARK: - Scenario Header

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
                    .background(Color.platformSecondaryBackground)
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
        HStack(spacing: 4) {
            Image(systemName: categoryIcon)
                .font(.caption2)
            Text(category.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
        }
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
        case .ethical: return .teal
        case .competitive: return .red
        case .innovation: return .cyan
        case .regulatory: return .brown
        }
    }

    private var categoryIcon: String {
        switch category {
        case .budget: return "dollarsign.circle"
        case .technical: return "gear"
        case .marketing: return "megaphone"
        case .hr: return "person.2"
        case .opportunity: return "lightbulb"
        case .ethical: return "scale.3d"
        case .competitive: return "flag.2.crossed"
        case .innovation: return "sparkles"
        case .regulatory: return "building.columns"
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
                .background(Color.platformCardBackground)
                .cornerRadius(8)
        }
    }
}

// MARK: - Decision Options

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

                RiskLevelBadge(riskLevel: option.riskLevel, isSelected: isSelected)

                Text("$\(Int(option.cost).formatted())")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : costColor)
            }

            Text(option.description)
                .font(.body)
                .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)

            // Impact hints instead of exact numbers
            ImpactHintRow(impact: option.impact, isSelected: isSelected)
        }
        .padding()
        .background(isSelected ? Color.accentColor : Color.platformCardBackground)
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

// MARK: - Risk Level Badge

struct RiskLevelBadge: View {
    let riskLevel: RiskLevel
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: riskLevel.icon)
                .font(.caption2)
            Text(riskLevel.rawValue)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(isSelected ? Color.white.opacity(0.2) : riskColor.opacity(0.15))
        .foregroundColor(isSelected ? .white : riskColor)
        .cornerRadius(4)
    }

    private var riskColor: Color {
        switch riskLevel {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

// MARK: - Impact Hints (vague directional hints instead of exact numbers)

struct ImpactHintRow: View {
    let impact: DecisionImpact
    let isSelected: Bool

    var body: some View {
        let hints = ImpactHint.fromImpact(impact)
        if !hints.isEmpty {
            HStack(spacing: 6) {
                ForEach(hints, id: \.metric) { hint in
                    ImpactHintChip(hint: hint, isSelected: isSelected)
                }
                Spacer()
            }
        }
    }
}

struct ImpactHintChip: View {
    let hint: ImpactHint
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: hint.direction == .positive ? "arrow.up" : hint.direction == .negative ? "arrow.down" : "minus")
                .font(.caption2)
            Text(hint.metric)
                .font(.caption2)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(isSelected ? Color.white.opacity(0.2) : hintColor.opacity(0.15))
        .foregroundColor(isSelected ? .white : hintColor)
        .cornerRadius(4)
    }

    private var hintColor: Color {
        switch hint.direction {
        case .positive: return .green
        case .negative: return .red
        case .neutral: return .gray
        }
    }
}

// MARK: - Agent Advice

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
        .background(Color.platformCardBackground)
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
