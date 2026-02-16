import SwiftUI
import CEOSimulationCore

struct AdvisorsView: View {
    let agentManager: AgentManager
    let gameController: GameController
    let agentResponses: [DepartmentType: AgentResponse]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if let scenario = gameController.currentScenario {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Department Head Advice")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        Text("Your department heads have analyzed the situation and are ready to share their perspectives:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ForEach(DepartmentType.allCases, id: \.self) { department in
                            if let response = agentResponses[department] {
                                AdvisorCard(
                                    department: department,
                                    response: response,
                                    scenario: scenario,
                                    company: gameController.company
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Advisors Standby")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Your department heads are ready to provide advice when the next scenario arrives.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .padding(.top)
        }
    }
}

struct AdvisorCard: View {
    let department: DepartmentType
    let response: AgentResponse
    let scenario: Scenario
    let company: Company
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AdvisorHeader(
                department: department,
                response: response,
                isExpanded: isExpanded
            ) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }
            
            Text(response.message)
                .font(.body)
                .lineSpacing(4)
            
            if let recommendedOption = response.recommendedOption,
               recommendedOption < scenario.options.count {
                RecommendationView(
                    option: scenario.options[recommendedOption],
                    optionIndex: recommendedOption
                )
            }
            
            if isExpanded {
                AdvisorDetailView(
                    department: department,
                    response: response,
                    company: company
                )
            }
        }
        .padding()
        .background(Color.platformCardBackground)
        .cornerRadius(12)
    }
}

struct AdvisorHeader: View {
    let department: DepartmentType
    let response: AgentResponse
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: department.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(department.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Department Head")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(response.mood.rawValue)
                    .font(.title2)
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct RecommendationView: View {
    let option: DecisionOption
    let optionIndex: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommendation")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Option \(optionIndex + 1): \(option.title)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(option.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Cost")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("$\(Int(option.cost).formatted())")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(option.cost == 0 ? .green : option.cost <= 10000 ? .orange : .red)
                }
            }
        }
        .padding(10)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

struct AdvisorDetailView: View {
    let department: DepartmentType
    let response: AgentResponse
    let company: Company
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Reasoning")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(response.reasoning)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(Color.platformSecondaryBackground)
                    .cornerRadius(6)
            }
            
            if let departmentData = company.departments.first(where: { $0.type == department }) {
                DepartmentStatusView(department: departmentData)
            }
            
            PersonalityTraitsView(department: department)
        }
    }
}

struct DepartmentStatusView: View {
    let department: Department
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Department Status")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            HStack {
                StatusMetric(
                    label: "Performance",
                    value: department.performance,
                    color: department.performance > 60 ? .green : department.performance > 40 ? .orange : .red
                )
                
                StatusMetric(
                    label: "Morale",
                    value: department.morale,
                    color: department.morale > 60 ? .green : department.morale > 40 ? .orange : .red
                )
                
                StatusMetric(
                    label: "Budget",
                    value: department.budget,
                    color: .blue,
                    isMonetary: true
                )
            }
        }
    }
}

struct StatusMetric: View {
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
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if isMonetary {
                Text("$\(Int(value).formatted())")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            } else {
                Text("\(Int(value))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
        }
        .padding(6)
        .background(color.opacity(0.1))
        .cornerRadius(4)
    }
}

struct PersonalityTraitsView: View {
    let department: DepartmentType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Advisor Profile")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            HStack {
                ForEach(getPersonalityTraits(), id: \.self) { trait in
                    Text(trait)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Spacer()
            }
        }
    }
    
    private func getPersonalityTraits() -> [String] {
        switch department {
        case .sales:
            return ["Results-Oriented", "Competitive", "Optimistic"]
        case .marketing:
            return ["Creative", "Brand-Focused", "Strategic"]
        case .engineering:
            return ["Technical", "Perfectionist", "Innovative"]
        case .hr:
            return ["Empathetic", "People-Focused", "Collaborative"]
        case .finance:
            return ["Analytical", "Cautious", "Detail-Oriented"]
        }
    }
}

#Preview {
    AdvisorsView(
        agentManager: AgentManager(),
        gameController: GameController(),
        agentResponses: [:]
    )
}