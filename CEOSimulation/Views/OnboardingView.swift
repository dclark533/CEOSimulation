import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "building.2.crop.circle",
            iconColors: [.blue, .indigo],
            title: "Welcome to CEO Simulation",
            body: "You're the new CEO of TechLeap Education. The board has high expectations — and the clock is already ticking. Can you lead the company to success?"
        ),
        OnboardingPage(
            icon: "lightbulb.fill",
            iconColors: [.orange, .yellow],
            title: "Make Strategic Decisions",
            body: "Each quarter brings a new business scenario. Pick one of four options — each choice shifts your budget, reputation, and team performance in different ways. Choose wisely."
        ),
        OnboardingPage(
            icon: "person.3.fill",
            iconColors: [.green, .teal],
            title: "Balance Five Departments",
            body: "Keep Sales, Marketing, Engineering, HR, and Finance all healthy. Ignore any department for too long and you'll face serious consequences when it counts most."
        ),
        OnboardingPage(
            icon: "brain.head.profile",
            iconColors: [.purple, .blue],
            title: "Consult Your Advisors",
            body: "Each department head has an opinion on every scenario. Tap the Advisors tab before you decide — their insights can mean the difference between a great quarter and a disaster."
        ),
        OnboardingPage(
            icon: "trophy.fill",
            iconColors: [.yellow, .orange],
            title: "Survive All 12 Quarters",
            body: "Lead the company through a full fiscal year without going bankrupt or tanking morale. Finish strong and earn your place on the global leaderboard. Good luck, CEO."
        )
    ]

    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button row
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            finish()
                        }
                        .foregroundColor(.secondary)
                        .padding()
                    }
                }

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Page indicator dots
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.blue : Color.secondary.opacity(0.35))
                            .frame(width: index == currentPage ? 20 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 24)

                // Action button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        finish()
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .indigo],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }

    private func finish() {
        hasSeenOnboarding = true
    }
}

// MARK: - Data model

private struct OnboardingPage {
    let icon: String
    let iconColors: [Color]
    let title: String
    let body: String
}

// MARK: - Single page layout

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: page.iconColors.map { $0.opacity(0.15) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)

                Image(systemName: page.icon)
                    .font(.system(size: 64, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: page.iconColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text(page.body)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
    }
}
