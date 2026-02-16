import SwiftUI
import CEOSimulationCore

struct ExitConfirmationView: View {
    let gameController: GameController
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("Exit Current Game?")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("You are about to exit the current game. Your progress will be lost.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                if gameController.isGameActive {
                    GameSummaryCard(summary: gameController.getGameSummary())
                }
                
                VStack(spacing: 12) {
                    Button("Exit to Welcome Screen") {
                        gameController.confirmExitGame()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(8)
                    
                    Button("Cancel") {
                        gameController.cancelExitGame()
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Exit Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        gameController.cancelExitGame()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct GameSummaryCard: View {
    let summary: GameSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Game Progress")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                SummaryRow(label: "Quarters Survived", value: "\(summary.quartersSurvived)")
                SummaryRow(label: "Scenarios Completed", value: "\(summary.scenariosCompleted)")
                SummaryRow(label: "Current Score", value: "\(summary.currentScore)")
                SummaryRow(label: "Performance Grade", value: summary.performanceGrade)
                SummaryRow(label: "Company Budget", value: "$\(Int(summary.finalBudget).formatted())")
                SummaryRow(label: "Reputation", value: "\(Int(summary.finalReputation))%")
            }
            
            if summary.isSuccessfulRun {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Strong Performance!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SummaryRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    ExitConfirmationView(gameController: {
        let controller = GameController()
        controller.startNewGame()
        return controller
    }())
}