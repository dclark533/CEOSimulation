# Game Center Setup (App Store Connect)

The app includes Game Center integration for leaderboards and achievements. The code is ready, but the following must be configured manually in App Store Connect before Game Center features will work in production.

## Prerequisites

1. Enable the **Game Center** capability for your App ID in the [Apple Developer portal](https://developer.apple.com/account/resources/identifiers)
2. Ensure your provisioning profiles are regenerated after enabling the capability

## Leaderboard Configuration

Create one leaderboard in App Store Connect under **App > Services > Game Center > Leaderboards**:

| Field | Value |
|-------|-------|
| **Type** | Classic |
| **Leaderboard Reference Name** | Total Score |
| **Leaderboard ID** | `com.ceosimulation.leaderboard.totalscore` |
| **Score Format Type** | Integer |
| **Sort Order** | High to Low |
| **Score Range** | 0 – 2000 (optional) |

Add at least one localization (e.g. English) with a display name like "Total Score".

## Achievement Configuration

Create six achievements in App Store Connect under **App > Services > Game Center > Achievements**:

| Achievement ID | Reference Name | Points | Hidden | Trigger |
|----------------|---------------|--------|--------|---------|
| `com.ceosimulation.achievement.firstquarter` | First Quarter | 10 | No | Survive 1+ quarters |
| `com.ceosimulation.achievement.survivor` | Survivor | 25 | No | Survive 8+ quarters (progressive) |
| `com.ceosimulation.achievement.perfectrun` | Perfect Run | 50 | No | Complete all 12 quarters |
| `com.ceosimulation.achievement.aplusceo` | A+ CEO | 50 | No | Score 900+ points |
| `com.ceosimulation.achievement.risktaker` | Risk Taker | 25 | No | Take 5+ high-risk decisions (progressive) |
| `com.ceosimulation.achievement.balancedleader` | Balanced Leader | 25 | No | All departments above 50% at game end |

For each achievement, add at least one localization with:
- **Title**: The achievement name from the table above
- **Pre-earned Description**: Hint about how to earn it
- **Earned Description**: Congratulatory message
- **Image**: 512x512 achievement artwork

## Testing

1. Create a **Sandbox tester** account in App Store Connect under Users and Access > Sandbox
2. On your test device, sign into Game Center with the sandbox account
3. Run the app — Game Center authentication should trigger automatically on launch
4. Complete a game to verify score submission and achievement reporting
5. Tap the "Leaderboard" button on the Game Over screen to verify the dashboard opens

## Code Reference

- **Manager**: `CEOSimulation/Managers/GameKitManager.swift` — all GameKit logic
- **Entitlements**: `CEOSimulation/CEOSimulation.entitlements` — Game Center capability
- **Authentication**: triggered in `CEOSimulationApp.swift` on app launch
- **Score submission**: triggered in `GameOverView` (inside `QuarterlyReportView.swift`) via `.task` modifier
- **Welcome screen**: shows Game Center button and access point when authenticated
