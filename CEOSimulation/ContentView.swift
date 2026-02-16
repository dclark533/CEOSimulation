import SwiftUI
import CEOSimulationCore

struct ContentView: View {
    @State private var gameController = GameController()
    @State private var agentManager = AgentManager()
    @State private var showingQuarterlyReport = false
    @State private var showingGameOver = false
    
    var body: some View {
        NavigationSplitView {
            Sidebar(gameController: gameController)
        } detail: {
            if gameController.isGameActive {
                GameView(
                    gameController: gameController,
                    agentManager: agentManager,
                    showingQuarterlyReport: $showingQuarterlyReport
                )
            } else {
                WelcomeView(gameController: gameController)
            }
        }
        .sheet(isPresented: $showingQuarterlyReport) {
            QuarterlyReportView(
                gameController: gameController,
                agentManager: agentManager
            )
        }
        .sheet(isPresented: $showingGameOver) {
            GameOverView(gameController: gameController)
        }
        .onChange(of: gameController.gameOverReason) { oldValue, newValue in
            if newValue != nil {
                showingGameOver = true
            }
        }
        .confirmationDialog(
            "Exit Game",
            isPresented: $gameController.showingExitConfirmation,
            titleVisibility: .visible
        ) {
            Button("Exit to Welcome Screen", role: .destructive) {
                gameController.confirmExitGame()
            }
            Button("Cancel", role: .cancel) {
                gameController.cancelExitGame()
            }
        } message: {
            Text("Are you sure you want to exit the current game? Your progress will be lost.")
        }
    }
}

struct Sidebar: View {
    let gameController: GameController

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CompanyMetricsView(company: gameController.company)

            if gameController.isGameActive {
                if let event = gameController.currentMarketEvent {
                    MarketEventSidebarView(event: event, quartersRemaining: gameController.marketEventQuartersRemaining)
                }

                DepartmentListView(departments: gameController.company.departments)
            }

            Spacer()

            GameControlsView(gameController: gameController)
        }
        .padding()
        .frame(minWidth: 280)
    }
}

struct MarketEventSidebarView: View {
    let event: MarketEvent
    let quartersRemaining: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: event.icon)
                    .foregroundColor(.indigo)
                Text("Market Conditions")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(event.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)

                Text("\(quartersRemaining) quarter\(quartersRemaining == 1 ? "" : "s") remaining")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.indigo)
            }
        }
        .padding()
        .background(Color.indigo.opacity(0.1))
        .cornerRadius(8)
    }
}

struct CompanyMetricsView: View {
    let company: Company
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Company Overview")
                .font(.headline)
            
            MetricRow(
                label: "Quarter",
                value: "\(company.quarter)",
                color: .primary
            )
            
            MetricRow(
                label: "Budget",
                value: "$\(Int(company.budget).formatted())",
                color: company.budget > 50000 ? .green : company.budget > 25000 ? .orange : .red
            )
            
            MetricRow(
                label: "Reputation",
                value: "\(Int(company.reputation))%",
                color: company.reputation > 60 ? .green : company.reputation > 40 ? .orange : .red
            )
            
            MetricRow(
                label: "Performance",
                value: "\(Int(company.overallPerformance))%",
                color: company.overallPerformance > 60 ? .green : company.overallPerformance > 40 ? .orange : .red
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

struct DepartmentListView: View {
    let departments: [Department]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Departments")
                .font(.headline)
            
            ForEach(departments, id: \.type.rawValue) { department in
                DepartmentRowView(department: department)
            }
        }
    }
}

struct DepartmentRowView: View {
    let department: Department

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: department.type.icon)
                    .foregroundColor(.blue)
                Text(department.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                if department.isNeglected {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            HStack {
                Text("Performance: \(Int(department.performance))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Morale: \(Int(department.morale))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if department.isNeglected {
                Text("Neglected - needs attention!")
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
            }
        }
        .padding(8)
        .background(department.isNeglected ? Color.orange.opacity(0.08) : Color(.systemGray6))
        .cornerRadius(6)
    }
}

struct GameControlsView: View {
    let gameController: GameController
    
    var body: some View {
        VStack(spacing: 12) {
            if !gameController.isGameActive {
                Button("Start New Game") {
                    gameController.startNewGame()
                }
                .buttonStyle(.borderedProminent)
            }
            
            if gameController.isGameActive {
                VStack(spacing: 8) {
                    Text("Score: \(gameController.getCurrentScore())")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Button("Pause Game") {
                        gameController.pauseGame()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Exit Game") {
                        gameController.requestExitGame()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            }
        }
    }
}

struct WelcomeView: View {
    let gameController: GameController
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "building.2.crop.circle")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("CEO Business Simulation")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Lead an education technology company through challenging business scenarios. Make strategic decisions, manage your team, and build a successful enterprise.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "person.3", title: "Manage 5 Departments", description: "Sales, Marketing, Engineering, HR, and Finance")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Dynamic Scenarios", description: "Face realistic business challenges and opportunities")
                FeatureRow(icon: "brain", title: "AI Department Heads", description: "Get advice from intelligent department agents")
                FeatureRow(icon: "trophy", title: "Performance Tracking", description: "Track your leadership effectiveness over time")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Button("Start Your CEO Journey") {
                gameController.startNewGame()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .frame(maxWidth: 600)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}