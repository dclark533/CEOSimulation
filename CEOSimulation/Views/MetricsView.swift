import SwiftUI
import CEOSimulationCore

struct MetricsView: View {
    let gameController: GameController
    @State private var selectedTimeframe: TimeFrame = .allTime
    @State private var selectedMetric: MetricType = .performance
    
    enum TimeFrame: String, CaseIterable {
        case lastQuarter = "Last Quarter"
        case lastYear = "Last Year" 
        case allTime = "All Time"
    }
    
    enum MetricType: String, CaseIterable {
        case performance = "Performance"
        case budget = "Budget"
        case reputation = "Reputation"
        case morale = "Morale"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                MetricsHeaderView(gameController: gameController)
                
                CurrentStatusGrid(company: gameController.company)
                
                DepartmentPerformanceChart(departments: gameController.company.departments)
                
                ScoreBreakdownView(gameController: gameController)
                
                RecentDecisionsView(gameController: gameController)
            }
            .padding()
        }
    }
}

struct MetricsHeaderView: View {
    let gameController: GameController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Performance Dashboard")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("Current Score: \(gameController.getCurrentScore())")
                    .font(.headline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            Text("Quarter \(gameController.company.quarter) • \(gameController.scenarioHistory.count) decisions made")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct CurrentStatusGrid: View {
    let company: Company
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Status")
                .font(.headline)
            
            LazyVGrid(columns: columns, spacing: 16) {
                MetricCard(
                    title: "Budget",
                    value: "$\(Int(company.budget).formatted())",
                    change: nil,
                    color: company.budget > 50000 ? .green : company.budget > 25000 ? .orange : .red,
                    icon: "dollarsign.circle"
                )
                
                MetricCard(
                    title: "Reputation",
                    value: "\(Int(company.reputation))%",
                    change: nil,
                    color: company.reputation > 60 ? .green : company.reputation > 40 ? .orange : .red,
                    icon: "star.circle"
                )
                
                MetricCard(
                    title: "Performance",
                    value: "\(Int(company.overallPerformance))%",
                    change: nil,
                    color: company.overallPerformance > 60 ? .green : company.overallPerformance > 40 ? .orange : .red,
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                MetricCard(
                    title: "Avg Morale",
                    value: "\(Int(company.departments.map(\.morale).reduce(0, +) / Double(company.departments.count)))%",
                    change: nil,
                    color: .blue,
                    icon: "heart.circle"
                )
            }
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let change: Double?
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
                if let change = change {
                    Text(change > 0 ? "+\(Int(change))%" : "\(Int(change))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(change > 0 ? .green : .red)
                }
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct DepartmentPerformanceChart: View {
    let departments: [Department]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Department Performance")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(departments, id: \.type.rawValue) { department in
                    DepartmentBarChart(department: department)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct DepartmentBarChart: View {
    let department: Department
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: department.type.icon)
                        .foregroundColor(.blue)
                    Text(department.type.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Text("\(Int(department.performance))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(department.performance > 60 ? .green : department.performance > 40 ? .orange : .red)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(department.performance > 60 ? .green : department.performance > 40 ? .orange : .red)
                        .frame(width: geometry.size.width * (department.performance / 100), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

struct ScoreBreakdownView: View {
    let gameController: GameController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score Breakdown")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                ScoreComponentRow(
                    label: "Base Performance",
                    value: calculateBaseScore(),
                    description: "Budget, reputation, and department performance"
                )
                
                ScoreComponentRow(
                    label: "Longevity Bonus",
                    value: gameController.company.quarter * 10,
                    description: "Bonus for surviving \(gameController.company.quarter) quarters"
                )
                
                ScoreComponentRow(
                    label: "Decision Quality",
                    value: 50, // Placeholder
                    description: "Consistency and strategic thinking"
                )
                
                Divider()
                
                HStack {
                    Text("Total Score")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(gameController.getCurrentScore())")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func calculateBaseScore() -> Int {
        let company = gameController.company
        let budgetScore = min(100, max(0, Int(company.budget / 1000)))
        let reputationScore = Int(company.reputation * 2)
        let performanceScore = Int(company.overallPerformance * 1.5)
        let departmentScore = company.departments.map { Int($0.performance + $0.morale) / 2 }.reduce(0, +)
        
        return budgetScore + reputationScore + performanceScore + departmentScore
    }
}

struct ScoreComponentRow: View {
    let label: String
    let value: Int
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(value)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct RecentDecisionsView: View {
    let gameController: GameController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Decisions")
                .font(.headline)
            
            if gameController.scenarioHistory.isEmpty {
                Text("No decisions made yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(gameController.scenarioHistory.suffix(5).enumerated()), id: \.offset) { index, scenario in
                        RecentDecisionRow(scenario: scenario, index: index)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
}

struct RecentDecisionRow: View {
    let scenario: Scenario
    let index: Int
    
    var body: some View {
        HStack(spacing: 12) {
            CategoryBadge(category: scenario.category)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(scenario.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text("Quarter \(scenario.quarter)")
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

#Preview {
    MetricsView(gameController: GameController())
}