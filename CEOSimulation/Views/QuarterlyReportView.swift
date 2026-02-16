import SwiftUI
import CEOSimulationCore

struct QuarterlyReportView: View {
    let gameController: GameController
    let agentManager: AgentManager
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $currentPage) {
                    OverviewReportPage(gameController: gameController)
                        .tag(0)
                    
                    DepartmentReportsPage(
                        gameController: gameController,
                        agentManager: agentManager
                    )
                        .tag(1)
                    
                    PerformanceAnalysisPage(gameController: gameController)
                        .tag(2)
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .always))
                #endif
                
                HStack {
                    Button("Previous") {
                        withAnimation {
                            currentPage = max(0, currentPage - 1)
                        }
                    }
                    .disabled(currentPage == 0)
                    
                    Spacer()
                    
                    Text("Page \(currentPage + 1) of 3")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if currentPage < 2 {
                        Button("Next") {
                            withAnimation {
                                currentPage = min(2, currentPage + 1)
                            }
                        }
                    } else {
                        Button("Continue Game") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
            .navigationTitle("Q\(gameController.company.quarter) Report")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct OverviewReportPage: View {
    let gameController: GameController

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ReportHeaderView(gameController: gameController)

                if let event = gameController.currentMarketEvent {
                    MarketConditionsReportView(
                        event: event,
                        quartersRemaining: gameController.marketEventQuartersRemaining
                    )
                }

                KeyMetricsGrid(company: gameController.company)

                QuarterHighlightsView(gameController: gameController)

                NextQuarterGoalsView(gameController: gameController)
            }
            .padding()
        }
    }
}

struct MarketConditionsReportView: View {
    let event: MarketEvent
    let quartersRemaining: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.indigo)
                Text("Market Conditions")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: event.icon)
                        .font(.title3)
                        .foregroundColor(.indigo)
                    Text(event.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }

                Text(event.description)
                    .font(.body)
                    .lineSpacing(4)

                HStack(spacing: 16) {
                    if event.modifier.budgetDrain != 0 {
                        MarketImpactChip(
                            label: "Budget",
                            value: event.modifier.budgetDrain,
                            isMonetary: true
                        )
                    }
                    if event.modifier.performanceChange != 0 {
                        MarketImpactChip(
                            label: "Performance",
                            value: event.modifier.performanceChange
                        )
                    }
                    if event.modifier.moraleChange != 0 {
                        MarketImpactChip(
                            label: "Morale",
                            value: event.modifier.moraleChange
                        )
                    }
                    if event.modifier.reputationChange != 0 {
                        MarketImpactChip(
                            label: "Reputation",
                            value: event.modifier.reputationChange
                        )
                    }
                }

                Text("\(quartersRemaining) quarter\(quartersRemaining == 1 ? "" : "s") remaining")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.indigo)
            }
            .padding()
            .background(Color.indigo.opacity(0.08))
            .cornerRadius(12)
        }
    }
}

struct MarketImpactChip: View {
    let label: String
    let value: Double
    var isMonetary: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: value > 0 ? "arrow.up" : "arrow.down")
                .font(.caption2)
            Text(label)
                .font(.caption2)
            if isMonetary {
                Text("$\(Int(abs(value)).formatted())/Q")
                    .font(.caption2)
                    .fontWeight(.semibold)
            } else {
                Text("\(value > 0 ? "+" : "")\(Int(value))%/Q")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(value > 0 ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
        .foregroundColor(value > 0 ? .green : .red)
        .cornerRadius(4)
    }
}

struct ReportHeaderView: View {
    let gameController: GameController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quarterly Report")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Quarter \(gameController.company.quarter) Performance Summary")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Overall Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(gameController.getCurrentScore())")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            
            Divider()
            
            Text(getQuarterSummary())
                .font(.body)
                .lineSpacing(4)
                .padding()
                .background(Color.platformCardBackground)
                .cornerRadius(12)
        }
    }
    
    private func getQuarterSummary() -> String {
        let company = gameController.company
        
        if company.overallPerformance > 70 && company.reputation > 60 {
            return "Excellent quarter! The company demonstrated strong performance across all metrics. Your leadership decisions have positioned us well for continued growth and success."
        } else if company.overallPerformance > 50 && company.reputation > 40 {
            return "Solid performance this quarter with steady progress toward our goals. There are opportunities for improvement, but the foundation remains strong."
        } else if company.overallPerformance > 30 || company.reputation > 30 {
            return "Mixed results this quarter with some challenges to address. The company shows resilience, but strategic adjustments may be needed moving forward."
        } else {
            return "Challenging quarter that tested the company's resilience. Immediate attention to performance and reputation issues will be critical for recovery."
        }
    }
}

struct KeyMetricsGrid: View {
    let company: Company
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Metrics")
                .font(.headline)
            
            LazyVGrid(columns: columns, spacing: 16) {
                QuarterMetricCard(
                    title: "Budget Position",
                    value: "$\(Int(company.budget).formatted())",
                    subtitle: getBudgetStatus(company.budget),
                    color: company.budget > 50000 ? .green : company.budget > 25000 ? .orange : .red,
                    icon: "banknote"
                )
                
                QuarterMetricCard(
                    title: "Company Reputation",
                    value: "\(Int(company.reputation))%",
                    subtitle: getReputationStatus(company.reputation),
                    color: company.reputation > 60 ? .green : company.reputation > 40 ? .orange : .red,
                    icon: "star.fill"
                )
                
                QuarterMetricCard(
                    title: "Overall Performance",
                    value: "\(Int(company.overallPerformance))%",
                    subtitle: getPerformanceStatus(company.overallPerformance),
                    color: company.overallPerformance > 60 ? .green : company.overallPerformance > 40 ? .orange : .red,
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                QuarterMetricCard(
                    title: "Team Morale",
                    value: "\(Int(company.departments.map(\.morale).reduce(0, +) / Double(company.departments.count)))%",
                    subtitle: getMoraleStatus(company.departments.map(\.morale).reduce(0, +) / Double(company.departments.count)),
                    color: .blue,
                    icon: "heart.fill"
                )
            }
        }
    }
    
    private func getBudgetStatus(_ budget: Double) -> String {
        if budget > 75000 { return "Strong position" }
        else if budget > 50000 { return "Stable" }
        else if budget > 25000 { return "Needs attention" }
        else { return "Critical" }
    }
    
    private func getReputationStatus(_ reputation: Double) -> String {
        if reputation > 70 { return "Excellent standing" }
        else if reputation > 50 { return "Good reputation" }
        else if reputation > 30 { return "Recovery needed" }
        else { return "Reputation crisis" }
    }
    
    private func getPerformanceStatus(_ performance: Double) -> String {
        if performance > 70 { return "Exceeding targets" }
        else if performance > 50 { return "Meeting expectations" }
        else if performance > 30 { return "Below targets" }
        else { return "Significant gaps" }
    }
    
    private func getMoraleStatus(_ morale: Double) -> String {
        if morale > 70 { return "High engagement" }
        else if morale > 50 { return "Positive" }
        else if morale > 30 { return "Concerns present" }
        else { return "Low morale" }
    }
}

struct QuarterMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .frame(height: 120)
        .background(Color.platformCardBackground)
        .cornerRadius(12)
    }
}

struct QuarterHighlightsView: View {
    let gameController: GameController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quarter Highlights")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                if !gameController.scenarioHistory.isEmpty {
                    let recentScenarios = Array(gameController.scenarioHistory.suffix(4))
                    
                    ForEach(Array(recentScenarios.enumerated()), id: \.offset) { index, scenario in
                        HighlightRow(
                            icon: getCategoryIcon(scenario.category),
                            title: scenario.title,
                            description: "Addressed \(scenario.category.rawValue.lowercased()) challenge"
                        )
                    }
                } else {
                    Text("No major decisions this quarter")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
    }
    
    private func getCategoryIcon(_ category: ScenarioCategory) -> String {
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

struct HighlightRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
    }
}

struct NextQuarterGoalsView: View {
    let gameController: GameController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Next Quarter Focus")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(getNextQuarterGoals(), id: \.title) { goal in
                    GoalRow(goal: goal)
                }
            }
            .padding()
            .background(Color.platformCardBackground)
            .cornerRadius(12)
        }
    }
    
    private func getNextQuarterGoals() -> [Goal] {
        let company = gameController.company
        var goals: [Goal] = []
        
        if company.budget < 50000 {
            goals.append(Goal(
                title: "Improve Cash Flow",
                description: "Focus on budget-positive decisions and cost optimization",
                priority: .high
            ))
        }
        
        if company.reputation < 50 {
            goals.append(Goal(
                title: "Rebuild Reputation",
                description: "Prioritize customer satisfaction and brand initiatives",
                priority: .high
            ))
        }
        
        if company.overallPerformance < 50 {
            goals.append(Goal(
                title: "Enhance Performance",
                description: "Address operational inefficiencies and boost productivity",
                priority: .medium
            ))
        }
        
        let avgMorale = company.departments.map(\.morale).reduce(0, +) / Double(company.departments.count)
        if avgMorale < 50 {
            goals.append(Goal(
                title: "Boost Team Morale",
                description: "Invest in employee satisfaction and workplace culture",
                priority: .medium
            ))
        }
        
        if goals.isEmpty {
            goals.append(Goal(
                title: "Maintain Excellence",
                description: "Continue strong performance across all areas",
                priority: .low
            ))
            goals.append(Goal(
                title: "Explore Growth Opportunities",
                description: "Look for strategic expansion and innovation",
                priority: .medium
            ))
        }
        
        return goals
    }
}

struct Goal {
    let title: String
    let description: String
    let priority: Priority
    
    enum Priority: String {
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .green
            }
        }
    }
}

struct GoalRow: View {
    let goal: Goal
    
    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(goal.priority.color)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(goal.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(goal.priority.rawValue)
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(goal.priority.color.opacity(0.2))
                .foregroundColor(goal.priority.color)
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
}

struct DepartmentReportsPage: View {
    let gameController: GameController
    let agentManager: AgentManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Department Reports")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                ForEach(gameController.company.departments, id: \.type.rawValue) { department in
                    DepartmentReportCard(
                        department: department,
                        agentManager: agentManager,
                        company: gameController.company
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
    }
}

struct DepartmentReportCard: View {
    let department: Department
    let agentManager: AgentManager
    let company: Company
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: department.type.icon)
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(department.type.rawValue)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Department Report")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Performance")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(Int(department.performance))%")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(department.performance > 60 ? .green : department.performance > 40 ? .orange : .red)
                }
            }

            if department.isNeglected {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("This department has been neglected for \(department.quartersSinceLastInvestment) quarters and is experiencing declining performance and morale.")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(10)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }

            // Agent's quarterly report
            if let agent = agentManager.agents.first(where: { $0.department == department.type }) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Department Head Summary")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(agent.provideQuarterlyReport(for: company))
                        .font(.body)
                        .lineSpacing(4)
                        .padding()
                        .background(Color.platformSecondaryBackground)
                        .cornerRadius(8)
                }
            }
            
            // Performance metrics
            HStack {
                DepartmentMetric(
                    label: "Performance",
                    value: department.performance,
                    color: department.performance > 60 ? .green : department.performance > 40 ? .orange : .red
                )
                
                DepartmentMetric(
                    label: "Morale",
                    value: department.morale,
                    color: department.morale > 60 ? .green : department.morale > 40 ? .orange : .red
                )
                
                DepartmentMetric(
                    label: "Budget",
                    value: department.budget,
                    color: .blue,
                    isMonetary: true
                )
            }
        }
        .padding()
        .background(Color.platformCardBackground)
        .cornerRadius(12)
    }
}

struct DepartmentMetric: View {
    let label: String
    let value: Double
    let color: Color
    let isMonetary: Bool
    
    init(label: String, value: Double, color: Color, isMonetary: Bool = false) {
        self.label = label
        self.value = value
        self.color = color
        self.isMonetary = isMonetary
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if isMonetary {
                Text("$\(Int(value).formatted())")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            } else {
                Text("\(Int(value))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

struct PerformanceAnalysisPage: View {
    let gameController: GameController
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Performance Analysis")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                if let analysis = getPerformanceAnalysis() {
                    VStack(alignment: .leading, spacing: 16) {
                        LeadershipStyleView(analysis: analysis)
                            .padding(.horizontal)
                        
                        StrengthsAndWeaknessesView(analysis: analysis)
                            .padding(.horizontal)
                        
                        DecisionHistoryView(gameController: gameController)
                            .padding(.horizontal)
                    }
                } else {
                    Text("Insufficient data for detailed analysis")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
            .padding(.top)
        }
    }
    
    private func getPerformanceAnalysis() -> PerformanceAnalysis? {
        // This would typically come from the ScoreManager
        // For now, creating a basic analysis
        return PerformanceAnalysis(
            totalScore: gameController.getCurrentScore(),
            quartersSurvived: gameController.company.quarter,
            decisionsMade: gameController.scenarioHistory.count,
            averageDecisionCost: 12000,
            strongestDepartment: .sales,
            weakestDepartment: .finance,
            keyStrengths: ["Strategic Thinking", "Financial Management"],
            areasForImprovement: ["Team Morale", "Innovation"],
            leadershipStyle: .balanced
        )
    }
}

struct LeadershipStyleView: View {
    let analysis: PerformanceAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Leadership Style")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(analysis.leadershipStyle.rawValue)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Spacer()
                }
                
                Text(analysis.leadershipStyle.description)
                    .font(.body)
                    .lineSpacing(4)
            }
            .padding()
            .background(Color.platformCardBackground)
            .cornerRadius(12)
        }
    }
}

struct StrengthsAndWeaknessesView: View {
    let analysis: PerformanceAnalysis
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Key Strengths")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                ForEach(analysis.keyStrengths, id: \.self) { strength in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text(strength)
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Areas to Improve")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                ForEach(analysis.areasForImprovement, id: \.self) { area in
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text(area)
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct DecisionHistoryView: View {
    let gameController: GameController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Decision Summary")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                DecisionSummaryRow(
                    label: "Total Decisions",
                    value: "\(gameController.scenarioHistory.count)"
                )
                
                DecisionSummaryRow(
                    label: "Quarters Survived",
                    value: "\(gameController.company.quarter)"
                )
                
                DecisionSummaryRow(
                    label: "Current Score",
                    value: "\(gameController.getCurrentScore())"
                )
            }
            .padding()
            .background(Color.platformCardBackground)
            .cornerRadius(12)
        }
    }
}

struct DecisionSummaryRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
    }
}

struct GameOverView: View {
    let gameController: GameController
    @Environment(\.dismiss) private var dismiss
    @State private var scoreSubmitted = false

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: gameController.company.quarter >= 12 ? "trophy.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 80))
                .foregroundColor(gameController.company.quarter >= 12 ? .yellow : .red)

            Text(gameController.company.quarter >= 12 ? "Congratulations!" : "Game Over")
                .font(.title)
                .fontWeight(.bold)

            if let reason = gameController.gameOverReason {
                Text(reason)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 12) {
                Text("Final Score: \(gameController.getCurrentScore())")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)

                Text("Quarters Survived: \(gameController.company.quarter)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if scoreSubmitted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Score submitted to Game Center")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            HStack(spacing: 16) {
                Button("Start New Game") {
                    dismiss()
                    gameController.startNewGame()
                }
                .buttonStyle(.borderedProminent)

                if GameKitManager.shared.isAuthenticated {
                    Button {
                        GameKitManager.shared.presentDashboard()
                    } label: {
                        Label("Leaderboard", systemImage: "trophy")
                    }
                    .buttonStyle(.bordered)
                }

                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .interactiveDismissDisabled()
        .task {
            guard GameKitManager.shared.isAuthenticated else { return }
            let summary = gameController.getGameSummary()
            let breakdown = gameController.getScoreBreakdown()
            await GameKitManager.shared.submitScore(breakdown.totalScore)
            await GameKitManager.shared.reportAchievements(for: summary, scoreBreakdown: breakdown)
            scoreSubmitted = true
        }
    }
}

#Preview {
    QuarterlyReportView(
        gameController: GameController(),
        agentManager: AgentManager()
    )
}