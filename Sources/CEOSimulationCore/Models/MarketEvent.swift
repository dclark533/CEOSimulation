import Foundation

public struct MarketEventModifier: Equatable, Sendable {
    public let budgetDrain: Double
    public let performanceChange: Double
    public let moraleChange: Double
    public let reputationChange: Double

    public init(budgetDrain: Double = 0, performanceChange: Double = 0, moraleChange: Double = 0, reputationChange: Double = 0) {
        self.budgetDrain = budgetDrain
        self.performanceChange = performanceChange
        self.moraleChange = moraleChange
        self.reputationChange = reputationChange
    }
}

public struct MarketEvent: Equatable, Sendable {
    public let name: String
    public let description: String
    public let duration: Int
    public let modifier: MarketEventModifier
    public let categoryWeightAdjustments: [ScenarioCategory: Double]
    public let icon: String

    public init(
        name: String,
        description: String,
        duration: Int,
        modifier: MarketEventModifier,
        categoryWeightAdjustments: [ScenarioCategory: Double] = [:],
        icon: String
    ) {
        self.name = name
        self.description = description
        self.duration = duration
        self.modifier = modifier
        self.categoryWeightAdjustments = categoryWeightAdjustments
        self.icon = icon
    }
}

public enum MarketEventPool {
    public static let events: [MarketEvent] = [
        MarketEvent(
            name: "Economic Recession",
            description: "A global economic downturn is squeezing budgets across the industry. Companies are cutting costs and delaying investments.",
            duration: 2,
            modifier: MarketEventModifier(budgetDrain: -3000, performanceChange: -2, moraleChange: -3, reputationChange: 0),
            categoryWeightAdjustments: [.budget: 0.3, .competitive: 0.1],
            icon: "chart.line.downtrend.xyaxis"
        ),
        MarketEvent(
            name: "Tech Boom",
            description: "Rapid technological advances are creating exciting new opportunities. Companies investing in tech are seeing outsized returns.",
            duration: 2,
            modifier: MarketEventModifier(budgetDrain: 0, performanceChange: 2, moraleChange: 2, reputationChange: 1),
            categoryWeightAdjustments: [.innovation: 0.3, .technical: 0.2],
            icon: "bolt.fill"
        ),
        MarketEvent(
            name: "Regulatory Crackdown",
            description: "Government regulators are increasing scrutiny on the education technology sector, requiring new compliance measures.",
            duration: 2,
            modifier: MarketEventModifier(budgetDrain: -2000, performanceChange: -1, moraleChange: -2, reputationChange: -1),
            categoryWeightAdjustments: [.regulatory: 0.4, .ethical: 0.2],
            icon: "building.columns"
        ),
        MarketEvent(
            name: "Talent War",
            description: "Competition for skilled workers has intensified. Salaries are rising and retention is becoming a key challenge.",
            duration: 1,
            modifier: MarketEventModifier(budgetDrain: -2500, performanceChange: -1, moraleChange: -4, reputationChange: 0),
            categoryWeightAdjustments: [.hr: 0.3, .competitive: 0.2],
            icon: "person.3.fill"
        ),
        MarketEvent(
            name: "Market Expansion",
            description: "New markets are opening up in emerging economies, creating significant growth opportunities for education technology.",
            duration: 2,
            modifier: MarketEventModifier(budgetDrain: 0, performanceChange: 1, moraleChange: 3, reputationChange: 2),
            categoryWeightAdjustments: [.opportunity: 0.3, .competitive: 0.1],
            icon: "globe"
        ),
        MarketEvent(
            name: "Supply Chain Crisis",
            description: "Global supply chain disruptions are increasing costs and delaying hardware and infrastructure projects.",
            duration: 1,
            modifier: MarketEventModifier(budgetDrain: -4000, performanceChange: -3, moraleChange: -1, reputationChange: 0),
            categoryWeightAdjustments: [.budget: 0.2, .technical: 0.2],
            icon: "shippingbox"
        ),
        MarketEvent(
            name: "Industry Disruption",
            description: "A major competitor has launched a revolutionary product that is reshaping customer expectations in the market.",
            duration: 2,
            modifier: MarketEventModifier(budgetDrain: 0, performanceChange: -2, moraleChange: -2, reputationChange: -2),
            categoryWeightAdjustments: [.competitive: 0.3, .innovation: 0.2],
            icon: "exclamationmark.octagon"
        ),
        MarketEvent(
            name: "Consumer Confidence Surge",
            description: "Consumer spending on education technology is at an all-time high. Companies are seeing increased demand across all segments.",
            duration: 1,
            modifier: MarketEventModifier(budgetDrain: 2000, performanceChange: 2, moraleChange: 2, reputationChange: 1),
            categoryWeightAdjustments: [.opportunity: 0.3, .marketing: 0.2],
            icon: "arrow.up.right.circle"
        ),
        MarketEvent(
            name: "Cybersecurity Threat Wave",
            description: "A wave of cyberattacks is targeting education technology companies. Security is now a top priority for all stakeholders.",
            duration: 1,
            modifier: MarketEventModifier(budgetDrain: -3000, performanceChange: -2, moraleChange: -3, reputationChange: -1),
            categoryWeightAdjustments: [.technical: 0.3, .regulatory: 0.2],
            icon: "lock.shield"
        ),
        MarketEvent(
            name: "Green Initiative Push",
            description: "Sustainability is becoming a key differentiator. Companies with strong environmental practices are gaining favor with stakeholders.",
            duration: 2,
            modifier: MarketEventModifier(budgetDrain: -1000, performanceChange: 0, moraleChange: 1, reputationChange: 2),
            categoryWeightAdjustments: [.ethical: 0.3, .regulatory: 0.1],
            icon: "leaf.fill"
        ),
    ]

    public static func randomEvent() -> MarketEvent? {
        guard Double.random(in: 0...1) < GameConstants.marketEventChance else { return nil }
        return events.randomElement()
    }
}
