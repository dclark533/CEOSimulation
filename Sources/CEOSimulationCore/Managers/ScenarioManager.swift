import Foundation

@MainActor
public class ScenarioManager {
    private let scenarioTemplates: [ScenarioCategory: [ScenarioTemplate]]

    public init() {
        self.scenarioTemplates = Self.createScenarioTemplates()
    }

    public func generateScenario(for company: Company, marketEvent: MarketEvent? = nil) -> Scenario {
        let category = selectScenarioCategory(for: company, marketEvent: marketEvent)
        let templates = scenarioTemplates[category] ?? []

        guard !templates.isEmpty else {
            return applyDifficultyScaling(to: createFallbackScenario(company: company), quarter: company.quarter)
        }

        let template = templates.randomElement()!
        let baseScenario = template.createScenario(for: company)
        return applyDifficultyScaling(to: baseScenario, quarter: company.quarter)
    }

    public func applyDifficultyScaling(to scenario: Scenario, quarter: Int) -> Scenario {
        let phase = DifficultyPhase.forQuarter(quarter)
        guard phase != .growth else { return scenario }

        let scaledOptions = scenario.options.map { option in
            let scaledImpact = DecisionImpact(
                performanceChange: option.impact.performanceChange * phase.impactMultiplier,
                moraleChange: option.impact.moraleChange * phase.impactMultiplier,
                budgetChange: option.impact.budgetChange * phase.costMultiplier,
                reputationChange: option.impact.reputationChange * phase.impactMultiplier,
                departmentSpecific: option.impact.departmentSpecific
            )
            return DecisionOption(
                title: option.title,
                description: option.description,
                cost: option.cost * phase.costMultiplier,
                impact: scaledImpact,
                riskLevel: option.riskLevel,
                impactVariance: option.impactVariance
            )
        }

        return Scenario(
            category: scenario.category,
            title: scenario.title,
            description: scenario.description,
            options: scaledOptions,
            quarter: scenario.quarter
        )
    }

    private func selectScenarioCategory(for company: Company, marketEvent: MarketEvent? = nil) -> ScenarioCategory {
        var weights: [ScenarioCategory: Double] = [:]

        if company.budget < GameConstants.lowBudgetThreshold {
            weights[.budget] = 0.4
        } else {
            weights[.opportunity] = 0.3
        }

        if company.reputation < GameConstants.lowReputationThreshold {
            weights[.marketing] = 0.3
        }

        if company.overallPerformance < GameConstants.lowPerformanceThreshold {
            weights[.technical] = 0.3
            weights[.hr] = 0.2
        }

        weights[.technical] = (weights[.technical] ?? 0) + 0.2
        weights[.hr] = (weights[.hr] ?? 0) + 0.1
        weights[.marketing] = (weights[.marketing] ?? 0) + 0.1
        weights[.budget] = (weights[.budget] ?? 0) + 0.1
        weights[.opportunity] = (weights[.opportunity] ?? 0) + 0.1
        weights[.ethical] = (weights[.ethical] ?? 0) + 0.05
        weights[.competitive] = (weights[.competitive] ?? 0) + 0.05
        weights[.innovation] = (weights[.innovation] ?? 0) + 0.05
        weights[.regulatory] = (weights[.regulatory] ?? 0) + 0.05

        let phase = DifficultyPhase.forQuarter(company.quarter)
        if phase == .enterprise {
            weights[.competitive] = (weights[.competitive] ?? 0) + 0.15
            weights[.innovation] = (weights[.innovation] ?? 0) + 0.1
            weights[.regulatory] = (weights[.regulatory] ?? 0) + 0.1
        }

        if let event = marketEvent {
            for (category, adjustment) in event.categoryWeightAdjustments {
                weights[category] = (weights[category] ?? 0) + adjustment
            }
        }

        return weightedRandomSelection(from: weights) ?? .technical
    }

    private func weightedRandomSelection(from weights: [ScenarioCategory: Double]) -> ScenarioCategory? {
        let totalWeight = weights.values.reduce(0, +)
        let randomValue = Double.random(in: 0...totalWeight)

        var currentWeight: Double = 0
        for (category, weight) in weights {
            currentWeight += weight
            if randomValue <= currentWeight {
                return category
            }
        }

        return weights.keys.first
    }

    private func createFallbackScenario(company: Company) -> Scenario {
        return Scenario(
            category: .technical,
            title: "System Maintenance",
            description: "Your IT systems need routine maintenance. How do you proceed?",
            options: [
                DecisionOption(
                    title: "Full maintenance",
                    description: "Comprehensive system overhaul",
                    cost: 5000,
                    impact: DecisionImpact(performanceChange: 10, budgetChange: -5000),
                    riskLevel: .low,
                    impactVariance: 0.08
                ),
                DecisionOption(
                    title: "Basic maintenance",
                    description: "Essential updates only",
                    cost: 2000,
                    impact: DecisionImpact(performanceChange: 5, budgetChange: -2000),
                    riskLevel: .low,
                    impactVariance: 0.05
                ),
                DecisionOption(
                    title: "Delay maintenance",
                    description: "Postpone maintenance to save money",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: -5, budgetChange: 0),
                    riskLevel: .medium,
                    impactVariance: 0.20
                )
            ],
            quarter: company.quarter
        )
    }

    private static func createScenarioTemplates() -> [ScenarioCategory: [ScenarioTemplate]] {
        return [
            .budget: [
                BudgetCrisisTemplate(),
                CashFlowTemplate(),
                InvestmentOpportunityTemplate()
            ],
            .technical: [
                SystemUpgradeTemplate(),
                SecurityBreachTemplate(),
                AIInvestmentTemplate(),
                TechDebtConflictTemplate()
            ],
            .marketing: [
                NegativeReviewTemplate(),
                CompetitorTemplate(),
                BrandingTemplate()
            ],
            .hr: [
                TalentRetentionTemplate(),
                WorkCultureTemplate(),
                RecruitmentTemplate(),
                DiversityInitiativeTemplate()
            ],
            .opportunity: [
                MarketExpansionTemplate(),
                PartnershipTemplate(),
                ProductLaunchTemplate(),
                AcquisitionTargetTemplate()
            ],
            .ethical: [
                DataPrivacyDilemmaTemplate(),
                WhistleblowerTemplate(),
                EnvironmentalShortcutTemplate()
            ],
            .competitive: [
                HostileTakeoverTemplate(),
                PriceWarTemplate(),
                TalentPoachingTemplate()
            ],
            .innovation: [
                MoonshotVRProjectTemplate(),
                PivotStrategyTemplate(),
                OpenSourceGambleTemplate(),
                BlockchainCredentialsTemplate()
            ],
            .regulatory: [
                AccessibilityComplianceTemplate(),
                DataLocalizationTemplate(),
                LicensingAuditTemplate()
            ]
        ]
    }
}

// MARK: - Template Protocol

@MainActor
private protocol ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario
}

// MARK: - Budget Templates

private struct BudgetCrisisTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .budget,
            title: "Budget Shortfall",
            description: "Unexpected expenses have created a budget crisis. The finance team is requesting immediate action to address the \(Int(abs(company.budget * 0.3))) shortfall.",
            options: [
                DecisionOption(
                    title: "Emergency cost cutting",
                    description: "Implement across-the-board spending cuts",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: -5, moraleChange: -10, budgetChange: company.budget * 0.1, reputationChange: -2),
                    riskLevel: .high,
                    impactVariance: 0.35
                ),
                DecisionOption(
                    title: "Seek emergency funding",
                    description: "Apply for a business loan",
                    cost: 1000,
                    impact: DecisionImpact(performanceChange: 0, moraleChange: -2, budgetChange: 25000, reputationChange: -1),
                    riskLevel: .medium,
                    impactVariance: 0.22
                ),
                DecisionOption(
                    title: "Delay payments",
                    description: "Negotiate extended payment terms",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: -2, moraleChange: -5, budgetChange: 5000, reputationChange: -5),
                    riskLevel: .low,
                    impactVariance: 0.08
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct CashFlowTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .budget,
            title: "Cash Flow Opportunity",
            description: "A large client is offering to pay a year in advance for a 15% discount on services.",
            options: [
                DecisionOption(
                    title: "Accept the deal",
                    description: "Immediate cash flow boost with reduced revenue",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 2, moraleChange: 3, budgetChange: company.budget * 0.2, reputationChange: 2),
                    riskLevel: .high,
                    impactVariance: 0.40
                ),
                DecisionOption(
                    title: "Counter-offer 10%",
                    description: "Negotiate a smaller discount",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 1, moraleChange: 1, budgetChange: company.budget * 0.15, reputationChange: 1),
                    riskLevel: .medium,
                    impactVariance: 0.20
                ),
                DecisionOption(
                    title: "Decline politely",
                    description: "Maintain full pricing structure",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 0, moraleChange: 0, budgetChange: 0, reputationChange: 0),
                    riskLevel: .low,
                    impactVariance: 0.05
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct InvestmentOpportunityTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .budget,
            title: "Investment Opportunity",
            description: "A venture capital firm is interested in investing in your company, offering significant funding for equity.",
            options: [
                DecisionOption(
                    title: "Accept full investment",
                    description: "Large funding with significant equity share",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 10, moraleChange: 5, budgetChange: 100000, reputationChange: 8),
                    riskLevel: .high,
                    impactVariance: 0.45
                ),
                DecisionOption(
                    title: "Negotiate terms",
                    description: "Smaller investment with better equity terms",
                    cost: 5000,
                    impact: DecisionImpact(performanceChange: 6, moraleChange: 2, budgetChange: 50000, reputationChange: 4),
                    riskLevel: .medium,
                    impactVariance: 0.22
                ),
                DecisionOption(
                    title: "Decline investment",
                    description: "Maintain full company control",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 0, moraleChange: 1, budgetChange: 0, reputationChange: 1),
                    riskLevel: .low,
                    impactVariance: 0.05
                )
            ],
            quarter: company.quarter
        )
    }
}

// MARK: - Technical Templates

private struct SystemUpgradeTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .technical,
            title: "System Upgrade Required",
            description: "Your current infrastructure is reaching capacity limits. An upgrade is needed to maintain service quality.",
            options: [
                DecisionOption(
                    title: "Enterprise upgrade",
                    description: "Top-tier infrastructure for future growth",
                    cost: 25000,
                    impact: DecisionImpact(performanceChange: 12, moraleChange: 5, budgetChange: -25000, reputationChange: 3, departmentSpecific: .engineering),
                    riskLevel: .high,
                    impactVariance: 0.35
                ),
                DecisionOption(
                    title: "Standard upgrade",
                    description: "Adequate improvements for current needs",
                    cost: 12000,
                    impact: DecisionImpact(performanceChange: 7, moraleChange: 2, budgetChange: -12000, reputationChange: 1, departmentSpecific: .engineering),
                    riskLevel: .medium,
                    impactVariance: 0.20
                ),
                DecisionOption(
                    title: "Minimal patches",
                    description: "Temporary fixes to buy time",
                    cost: 3000,
                    impact: DecisionImpact(performanceChange: 2, moraleChange: -2, budgetChange: -3000, reputationChange: -1, departmentSpecific: .engineering),
                    riskLevel: .low,
                    impactVariance: 0.08
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct SecurityBreachTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .technical,
            title: "Security Vulnerability",
            description: "Your security team has discovered a potential vulnerability in your student data systems.",
            options: [
                DecisionOption(
                    title: "Immediate full audit",
                    description: "Comprehensive security review and fixes",
                    cost: 20000,
                    impact: DecisionImpact(performanceChange: 8, moraleChange: 5, budgetChange: -20000, reputationChange: 5, departmentSpecific: .engineering),
                    riskLevel: .high,
                    impactVariance: 0.38
                ),
                DecisionOption(
                    title: "Patch critical issues",
                    description: "Address the most urgent vulnerabilities",
                    cost: 8000,
                    impact: DecisionImpact(performanceChange: 4, moraleChange: 2, budgetChange: -8000, reputationChange: 2, departmentSpecific: .engineering),
                    riskLevel: .medium,
                    impactVariance: 0.22
                ),
                DecisionOption(
                    title: "Monitor and assess",
                    description: "Keep watching without immediate action",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: -3, moraleChange: -5, budgetChange: 0, reputationChange: -10),
                    riskLevel: .low,
                    impactVariance: 0.10
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct AIInvestmentTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .technical,
            title: "AI Integration Opportunity",
            description: "Your engineering team has proposed implementing AI-driven learning systems to gain a competitive advantage in the education market.",
            options: [
                DecisionOption(
                    title: "Full AI investment",
                    description: "Major competitive advantage, high cost",
                    cost: 35000,
                    impact: DecisionImpact(performanceChange: 15, moraleChange: 10, budgetChange: -35000, reputationChange: 8, departmentSpecific: .engineering),
                    riskLevel: .high,
                    impactVariance: 0.45
                ),
                DecisionOption(
                    title: "Gradual integration",
                    description: "Steady improvement, moderate cost",
                    cost: 15000,
                    impact: DecisionImpact(performanceChange: 8, moraleChange: 5, budgetChange: -15000, reputationChange: 3, departmentSpecific: .engineering),
                    riskLevel: .medium,
                    impactVariance: 0.22
                ),
                DecisionOption(
                    title: "Wait and watch",
                    description: "No cost, but risk falling behind",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: -3, moraleChange: -2, budgetChange: 0, reputationChange: -1),
                    riskLevel: .low,
                    impactVariance: 0.08
                )
            ],
            quarter: company.quarter
        )
    }
}

// MARK: - Marketing Templates

private struct NegativeReviewTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .marketing,
            title: "Viral Negative Review",
            description: "A negative review of your educational platform has gone viral on social media, threatening your company's reputation.",
            options: [
                DecisionOption(
                    title: "Comprehensive PR campaign",
                    description: "Full damage control and reputation repair",
                    cost: 15000,
                    impact: DecisionImpact(performanceChange: 5, moraleChange: 0, budgetChange: -15000, reputationChange: 12, departmentSpecific: .marketing),
                    riskLevel: .high,
                    impactVariance: 0.38
                ),
                DecisionOption(
                    title: "Influencer counter-narrative",
                    description: "Partner with influencers to share positive stories",
                    cost: 8000,
                    impact: DecisionImpact(performanceChange: 2, moraleChange: 0, budgetChange: -8000, reputationChange: 7, departmentSpecific: .marketing),
                    riskLevel: .medium,
                    impactVariance: 0.25
                ),
                DecisionOption(
                    title: "Wait for storm to pass",
                    description: "Let the controversy die down naturally",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: -5, moraleChange: -5, budgetChange: 0, reputationChange: -8),
                    riskLevel: .low,
                    impactVariance: 0.10
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct CompetitorTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .marketing,
            title: "Competitor Launch",
            description: "A well-funded competitor has launched a similar educational platform with aggressive pricing.",
            options: [
                DecisionOption(
                    title: "Price matching campaign",
                    description: "Match competitor pricing with marketing push",
                    cost: 18000,
                    impact: DecisionImpact(performanceChange: 3, moraleChange: -2, budgetChange: -18000, reputationChange: 4, departmentSpecific: .marketing),
                    riskLevel: .high,
                    impactVariance: 0.40
                ),
                DecisionOption(
                    title: "Feature differentiation",
                    description: "Highlight unique features and value",
                    cost: 10000,
                    impact: DecisionImpact(performanceChange: 5, moraleChange: 3, budgetChange: -10000, reputationChange: 3, departmentSpecific: .marketing),
                    riskLevel: .medium,
                    impactVariance: 0.22
                ),
                DecisionOption(
                    title: "Focus on retention",
                    description: "Strengthen relationships with existing clients",
                    cost: 5000,
                    impact: DecisionImpact(performanceChange: 2, moraleChange: 2, budgetChange: -5000, reputationChange: 1),
                    riskLevel: .low,
                    impactVariance: 0.08
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct BrandingTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .marketing,
            title: "Rebranding Initiative",
            description: "Marketing suggests a complete rebrand to appeal to a younger demographic in the education sector.",
            options: [
                DecisionOption(
                    title: "Complete rebrand",
                    description: "Full visual identity and messaging overhaul",
                    cost: 25000,
                    impact: DecisionImpact(performanceChange: 6, moraleChange: 3, budgetChange: -25000, reputationChange: 8, departmentSpecific: .marketing),
                    riskLevel: .high,
                    impactVariance: 0.42
                ),
                DecisionOption(
                    title: "Gradual refresh",
                    description: "Incremental updates to brand elements",
                    cost: 10000,
                    impact: DecisionImpact(performanceChange: 3, moraleChange: 2, budgetChange: -10000, reputationChange: 3, departmentSpecific: .marketing),
                    riskLevel: .medium,
                    impactVariance: 0.20
                ),
                DecisionOption(
                    title: "Keep current brand",
                    description: "Maintain existing brand identity",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 0, moraleChange: 0, budgetChange: 0, reputationChange: -1),
                    riskLevel: .low,
                    impactVariance: 0.05
                )
            ],
            quarter: company.quarter
        )
    }
}

// MARK: - HR Templates

private struct TalentRetentionTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .hr,
            title: "Talent Retention Crisis",
            description: "Several key employees are considering leaving for competitor offers. HR needs to take action to retain talent.",
            options: [
                DecisionOption(
                    title: "Competitive salary review",
                    description: "Across-the-board salary increases and bonuses",
                    cost: 30000,
                    impact: DecisionImpact(performanceChange: 8, moraleChange: 15, budgetChange: -30000, reputationChange: 2, departmentSpecific: .hr),
                    riskLevel: .high,
                    impactVariance: 0.35
                ),
                DecisionOption(
                    title: "Enhanced benefits package",
                    description: "Improve benefits without salary changes",
                    cost: 12000,
                    impact: DecisionImpact(performanceChange: 4, moraleChange: 8, budgetChange: -12000, reputationChange: 1, departmentSpecific: .hr),
                    riskLevel: .medium,
                    impactVariance: 0.22
                ),
                DecisionOption(
                    title: "Flexible work arrangements",
                    description: "Offer remote work and flexible schedules",
                    cost: 2000,
                    impact: DecisionImpact(performanceChange: 2, moraleChange: 6, budgetChange: -2000, reputationChange: 1, departmentSpecific: .hr),
                    riskLevel: .low,
                    impactVariance: 0.08
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct WorkCultureTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .hr,
            title: "Work Culture Assessment",
            description: "An employee survey reveals concerns about work-life balance and company culture. HR recommends initiatives to address these issues.",
            options: [
                DecisionOption(
                    title: "Culture transformation",
                    description: "Comprehensive culture improvement program",
                    cost: 20000,
                    impact: DecisionImpact(performanceChange: 8, moraleChange: 12, budgetChange: -20000, reputationChange: 3, departmentSpecific: .hr),
                    riskLevel: .high,
                    impactVariance: 0.38
                ),
                DecisionOption(
                    title: "Targeted improvements",
                    description: "Address specific concerns with focused initiatives",
                    cost: 8000,
                    impact: DecisionImpact(performanceChange: 4, moraleChange: 6, budgetChange: -8000, reputationChange: 1, departmentSpecific: .hr),
                    riskLevel: .medium,
                    impactVariance: 0.20
                ),
                DecisionOption(
                    title: "Acknowledge concerns",
                    description: "Thank employees for feedback without major changes",
                    cost: 1000,
                    impact: DecisionImpact(performanceChange: 0, moraleChange: -2, budgetChange: -1000, reputationChange: 0, departmentSpecific: .hr),
                    riskLevel: .low,
                    impactVariance: 0.08
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct RecruitmentTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .hr,
            title: "Talent Acquisition",
            description: "Your company needs to expand the team to handle growing client demands. HR has identified several recruitment strategies.",
            options: [
                DecisionOption(
                    title: "Premium recruitment",
                    description: "Hire top-tier talent with competitive packages",
                    cost: 35000,
                    impact: DecisionImpact(performanceChange: 12, moraleChange: 5, budgetChange: -35000, reputationChange: 2, departmentSpecific: .hr),
                    riskLevel: .high,
                    impactVariance: 0.40
                ),
                DecisionOption(
                    title: "Standard hiring",
                    description: "Hire qualified candidates at market rates",
                    cost: 18000,
                    impact: DecisionImpact(performanceChange: 6, moraleChange: 2, budgetChange: -18000, reputationChange: 1, departmentSpecific: .hr),
                    riskLevel: .medium,
                    impactVariance: 0.22
                ),
                DecisionOption(
                    title: "Internal promotion",
                    description: "Promote existing employees to fill roles",
                    cost: 5000,
                    impact: DecisionImpact(performanceChange: 3, moraleChange: 8, budgetChange: -5000, reputationChange: 0),
                    riskLevel: .low,
                    impactVariance: 0.08
                )
            ],
            quarter: company.quarter
        )
    }
}

// MARK: - Opportunity Templates

private struct MarketExpansionTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .opportunity,
            title: "International Expansion",
            description: "An opportunity has emerged to expand into the European education market through a local partnership.",
            options: [
                DecisionOption(
                    title: "Full partnership",
                    description: "Commit significant resources for major expansion",
                    cost: 45000,
                    impact: DecisionImpact(performanceChange: 12, moraleChange: 8, budgetChange: -45000, reputationChange: 6),
                    riskLevel: .high,
                    impactVariance: 0.45
                ),
                DecisionOption(
                    title: "Pilot program",
                    description: "Start small with a limited market test",
                    cost: 15000,
                    impact: DecisionImpact(performanceChange: 5, moraleChange: 3, budgetChange: -15000, reputationChange: 2),
                    riskLevel: .medium,
                    impactVariance: 0.22
                ),
                DecisionOption(
                    title: "Decline opportunity",
                    description: "Focus on domestic market for now",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 0, moraleChange: -1, budgetChange: 0, reputationChange: 0),
                    riskLevel: .low,
                    impactVariance: 0.05
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct PartnershipTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .opportunity,
            title: "Strategic Partnership",
            description: "A major educational publisher is proposing a partnership to integrate your platform with their content library.",
            options: [
                DecisionOption(
                    title: "Exclusive partnership",
                    description: "Deep integration with exclusive content access",
                    cost: 15000,
                    impact: DecisionImpact(performanceChange: 15, moraleChange: 5, budgetChange: -15000, reputationChange: 10),
                    riskLevel: .high,
                    impactVariance: 0.40
                ),
                DecisionOption(
                    title: "Non-exclusive partnership",
                    description: "Flexible arrangement allowing other partnerships",
                    cost: 8000,
                    impact: DecisionImpact(performanceChange: 8, moraleChange: 3, budgetChange: -8000, reputationChange: 5),
                    riskLevel: .medium,
                    impactVariance: 0.20
                ),
                DecisionOption(
                    title: "Decline partnership",
                    description: "Maintain independence and develop own content",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 2, moraleChange: 0, budgetChange: 0, reputationChange: 0),
                    riskLevel: .low,
                    impactVariance: 0.05
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct ProductLaunchTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .opportunity,
            title: "New Product Launch",
            description: "Your product team has developed a new feature for personalized learning paths. How should you approach the launch?",
            options: [
                DecisionOption(
                    title: "Full marketing launch",
                    description: "Comprehensive marketing campaign with PR push",
                    cost: 22000,
                    impact: DecisionImpact(performanceChange: 10, moraleChange: 6, budgetChange: -22000, reputationChange: 8),
                    riskLevel: .high,
                    impactVariance: 0.42
                ),
                DecisionOption(
                    title: "Soft launch to beta users",
                    description: "Release to select customers for feedback",
                    cost: 5000,
                    impact: DecisionImpact(performanceChange: 5, moraleChange: 3, budgetChange: -5000, reputationChange: 3),
                    riskLevel: .medium,
                    impactVariance: 0.22
                ),
                DecisionOption(
                    title: "Internal testing only",
                    description: "Continue testing before any customer release",
                    cost: 2000,
                    impact: DecisionImpact(performanceChange: 2, moraleChange: 1, budgetChange: -2000, reputationChange: 0),
                    riskLevel: .low,
                    impactVariance: 0.08
                )
            ],
            quarter: company.quarter
        )
    }
}

// MARK: - Ethical Templates

private struct DataPrivacyDilemmaTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .ethical,
            title: "Data Privacy Dilemma",
            description: "A partner wants access to student learning data for research. The data could improve AI models, but parents haven't consented to third-party sharing.",
            options: [
                DecisionOption(
                    title: "Share anonymized data",
                    description: "Strip identifiers and share aggregate patterns for mutual benefit",
                    cost: 5000,
                    impact: DecisionImpact(performanceChange: 6, moraleChange: -3, budgetChange: 10000, reputationChange: -4),
                    riskLevel: .high,
                    impactVariance: 0.40
                ),
                DecisionOption(
                    title: "Decline and build in-house",
                    description: "Keep all data internal and develop your own research capability",
                    cost: 20000,
                    impact: DecisionImpact(performanceChange: 4, moraleChange: 5, budgetChange: -20000, reputationChange: 6),
                    riskLevel: .medium,
                    impactVariance: 0.25
                ),
                DecisionOption(
                    title: "Seek explicit consent first",
                    description: "Run a consent campaign before any data sharing, delaying the deal",
                    cost: 8000,
                    impact: DecisionImpact(performanceChange: 2, moraleChange: 3, budgetChange: -3000, reputationChange: 4),
                    riskLevel: .medium,
                    impactVariance: 0.20
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct WhistleblowerTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .ethical,
            title: "Whistleblower Report",
            description: "An employee has reported that a senior manager has been inflating performance metrics in quarterly reports to the board.",
            options: [
                DecisionOption(
                    title: "Full independent investigation",
                    description: "Hire external auditors and suspend the manager pending results",
                    cost: 25000,
                    impact: DecisionImpact(performanceChange: -5, moraleChange: 4, budgetChange: -25000, reputationChange: 8),
                    riskLevel: .high,
                    impactVariance: 0.35
                ),
                DecisionOption(
                    title: "Quiet internal review",
                    description: "Handle internally without public disclosure",
                    cost: 5000,
                    impact: DecisionImpact(performanceChange: -2, moraleChange: -4, budgetChange: -5000, reputationChange: -3),
                    riskLevel: .medium,
                    impactVariance: 0.30
                ),
                DecisionOption(
                    title: "Dismiss the report",
                    description: "Trust the manager's explanation and move on",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 0, moraleChange: -8, budgetChange: 0, reputationChange: -6),
                    riskLevel: .high,
                    impactVariance: 0.45
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct EnvironmentalShortcutTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .ethical,
            title: "Environmental Shortcut",
            description: "Your data center provider offers a 40% cost reduction by moving to a region with lax environmental regulations and cheaper coal-powered energy.",
            options: [
                DecisionOption(
                    title: "Take the cheap option",
                    description: "Significant savings but potential backlash if discovered",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 2, moraleChange: -6, budgetChange: 15000, reputationChange: -8),
                    riskLevel: .high,
                    impactVariance: 0.45
                ),
                DecisionOption(
                    title: "Invest in green infrastructure",
                    description: "Move to renewable-powered servers at a premium",
                    cost: 20000,
                    impact: DecisionImpact(performanceChange: 3, moraleChange: 6, budgetChange: -20000, reputationChange: 10),
                    riskLevel: .medium,
                    impactVariance: 0.22
                ),
                DecisionOption(
                    title: "Stay with current provider",
                    description: "No change, no savings, no risk",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 0, moraleChange: 0, budgetChange: 0, reputationChange: 0),
                    riskLevel: .low,
                    impactVariance: 0.05
                )
            ],
            quarter: company.quarter
        )
    }
}

// MARK: - Competitive Templates

private struct HostileTakeoverTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .competitive,
            title: "Hostile Acquisition Attempt",
            description: "A larger competitor is quietly buying up shares and approaching your board members about an acquisition. You need to respond strategically.",
            options: [
                DecisionOption(
                    title: "Poison pill defense",
                    description: "Implement anti-takeover measures that dilute the acquirer's stake",
                    cost: 15000,
                    impact: DecisionImpact(performanceChange: -3, moraleChange: -5, budgetChange: -15000, reputationChange: 5),
                    riskLevel: .high,
                    impactVariance: 0.40
                ),
                DecisionOption(
                    title: "Negotiate a white knight",
                    description: "Find a friendly partner willing to counter-bid at better terms",
                    cost: 10000,
                    impact: DecisionImpact(performanceChange: 5, moraleChange: 2, budgetChange: 30000, reputationChange: 3),
                    riskLevel: .high,
                    impactVariance: 0.45
                ),
                DecisionOption(
                    title: "Open dialogue",
                    description: "Meet with the acquirer to understand their vision and explore options",
                    cost: 2000,
                    impact: DecisionImpact(performanceChange: 0, moraleChange: -3, budgetChange: -2000, reputationChange: -2),
                    riskLevel: .medium,
                    impactVariance: 0.25
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct PriceWarTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .competitive,
            title: "Price War",
            description: "Three competitors have slashed prices by 50%. Customers are asking why your platform costs more. Revenue is starting to slip.",
            options: [
                DecisionOption(
                    title: "Match their prices",
                    description: "Slash prices to stay competitive, accepting margin pain",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 3, moraleChange: -4, budgetChange: -20000, reputationChange: 2),
                    riskLevel: .high,
                    impactVariance: 0.38
                ),
                DecisionOption(
                    title: "Premium positioning",
                    description: "Double down on quality and justify the price with new features",
                    cost: 15000,
                    impact: DecisionImpact(performanceChange: 6, moraleChange: 4, budgetChange: -15000, reputationChange: 5),
                    riskLevel: .medium,
                    impactVariance: 0.25
                ),
                DecisionOption(
                    title: "Freemium model",
                    description: "Offer a free tier to compete, upsell premium features",
                    cost: 10000,
                    impact: DecisionImpact(performanceChange: 4, moraleChange: -2, budgetChange: -10000, reputationChange: 3),
                    riskLevel: .high,
                    impactVariance: 0.42
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct TalentPoachingTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .competitive,
            title: "Talent Poaching",
            description: "A competitor is aggressively recruiting your top engineers with 40% salary premiums. Three key developers have already received offers.",
            options: [
                DecisionOption(
                    title: "Counter-offers for everyone",
                    description: "Match competitor salaries across the engineering team",
                    cost: 35000,
                    impact: DecisionImpact(performanceChange: 5, moraleChange: 8, budgetChange: -35000, reputationChange: 1, departmentSpecific: .engineering),
                    riskLevel: .high,
                    impactVariance: 0.35
                ),
                DecisionOption(
                    title: "Retention through equity",
                    description: "Offer stock options and vesting bonuses to key talent",
                    cost: 10000,
                    impact: DecisionImpact(performanceChange: 3, moraleChange: 5, budgetChange: -10000, reputationChange: 2, departmentSpecific: .engineering),
                    riskLevel: .medium,
                    impactVariance: 0.22
                ),
                DecisionOption(
                    title: "Let them go and hire fresh",
                    description: "Accept departures and recruit new talent at market rates",
                    cost: 8000,
                    impact: DecisionImpact(performanceChange: -6, moraleChange: -8, budgetChange: -8000, reputationChange: -2, departmentSpecific: .engineering),
                    riskLevel: .medium,
                    impactVariance: 0.28
                )
            ],
            quarter: company.quarter
        )
    }
}

// MARK: - Innovation Templates

private struct MoonshotVRProjectTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .innovation,
            title: "Moonshot VR Project",
            description: "Your R&D team has a breakthrough VR classroom prototype. It's unproven technology but could revolutionize remote learning if it works.",
            options: [
                DecisionOption(
                    title: "Go all-in on VR",
                    description: "Dedicate significant resources to develop and launch the VR platform",
                    cost: 50000,
                    impact: DecisionImpact(performanceChange: 18, moraleChange: 10, budgetChange: -50000, reputationChange: 12),
                    riskLevel: .high,
                    impactVariance: 0.50
                ),
                DecisionOption(
                    title: "Small pilot program",
                    description: "Test with 3 partner schools before committing further",
                    cost: 15000,
                    impact: DecisionImpact(performanceChange: 6, moraleChange: 5, budgetChange: -15000, reputationChange: 4),
                    riskLevel: .medium,
                    impactVariance: 0.25
                ),
                DecisionOption(
                    title: "Shelve and monitor",
                    description: "File the patent but wait for market readiness",
                    cost: 3000,
                    impact: DecisionImpact(performanceChange: -2, moraleChange: -4, budgetChange: -3000, reputationChange: 0),
                    riskLevel: .low,
                    impactVariance: 0.08
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct PivotStrategyTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .innovation,
            title: "Strategic Pivot",
            description: "Market analysis suggests corporate training is growing 3x faster than K-12 education. Should you pivot your core product?",
            options: [
                DecisionOption(
                    title: "Full pivot to corporate",
                    description: "Abandon K-12 and rebuild for enterprise customers",
                    cost: 30000,
                    impact: DecisionImpact(performanceChange: -8, moraleChange: -6, budgetChange: -30000, reputationChange: -5),
                    riskLevel: .high,
                    impactVariance: 0.48
                ),
                DecisionOption(
                    title: "Dual-track approach",
                    description: "Maintain K-12 while building a corporate division",
                    cost: 20000,
                    impact: DecisionImpact(performanceChange: 5, moraleChange: 2, budgetChange: -20000, reputationChange: 3),
                    riskLevel: .medium,
                    impactVariance: 0.25
                ),
                DecisionOption(
                    title: "Double down on K-12",
                    description: "Ignore the trend and strengthen your current market position",
                    cost: 10000,
                    impact: DecisionImpact(performanceChange: 4, moraleChange: 4, budgetChange: -10000, reputationChange: 2),
                    riskLevel: .low,
                    impactVariance: 0.10
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct OpenSourceGambleTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .innovation,
            title: "Open Source Gamble",
            description: "Your CTO proposes open-sourcing the core platform to build a developer community. It could attract contributors but also enable competitors.",
            options: [
                DecisionOption(
                    title: "Open source everything",
                    description: "Release the full platform as open source with enterprise add-ons",
                    cost: 5000,
                    impact: DecisionImpact(performanceChange: 8, moraleChange: 8, budgetChange: -15000, reputationChange: 10),
                    riskLevel: .high,
                    impactVariance: 0.48
                ),
                DecisionOption(
                    title: "Open source non-core tools",
                    description: "Release utilities and plugins, keep the platform proprietary",
                    cost: 3000,
                    impact: DecisionImpact(performanceChange: 4, moraleChange: 4, budgetChange: -3000, reputationChange: 5),
                    riskLevel: .medium,
                    impactVariance: 0.22
                ),
                DecisionOption(
                    title: "Keep everything proprietary",
                    description: "Protect intellectual property and maintain competitive moat",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 0, moraleChange: -3, budgetChange: 0, reputationChange: -1),
                    riskLevel: .low,
                    impactVariance: 0.08
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct BlockchainCredentialsTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .innovation,
            title: "Blockchain Credentials",
            description: "A blockchain startup proposes building verifiable digital credentials for your platform's certifications. It's cutting-edge but unproven at scale.",
            options: [
                DecisionOption(
                    title: "Full blockchain integration",
                    description: "Build comprehensive credential verification on blockchain",
                    cost: 25000,
                    impact: DecisionImpact(performanceChange: 10, moraleChange: 5, budgetChange: -25000, reputationChange: 8, departmentSpecific: .engineering),
                    riskLevel: .high,
                    impactVariance: 0.45
                ),
                DecisionOption(
                    title: "Limited partnership",
                    description: "Pilot with one certificate program to test the technology",
                    cost: 8000,
                    impact: DecisionImpact(performanceChange: 4, moraleChange: 3, budgetChange: -8000, reputationChange: 3, departmentSpecific: .engineering),
                    riskLevel: .medium,
                    impactVariance: 0.25
                ),
                DecisionOption(
                    title: "Wait for maturity",
                    description: "Blockchain credentials aren't proven enough yet for education",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: -1, moraleChange: -2, budgetChange: 0, reputationChange: 0),
                    riskLevel: .low,
                    impactVariance: 0.08
                )
            ],
            quarter: company.quarter
        )
    }
}

// MARK: - Regulatory Templates

private struct AccessibilityComplianceTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .regulatory,
            title: "Accessibility Compliance",
            description: "New regulations require all educational platforms to meet WCAG 2.2 AA accessibility standards within 6 months. Your platform has significant gaps.",
            options: [
                DecisionOption(
                    title: "Full compliance overhaul",
                    description: "Rebuild UI components to exceed standards with AAA rating",
                    cost: 30000,
                    impact: DecisionImpact(performanceChange: 6, moraleChange: 5, budgetChange: -30000, reputationChange: 8, departmentSpecific: .engineering),
                    riskLevel: .medium,
                    impactVariance: 0.22
                ),
                DecisionOption(
                    title: "Minimum viable compliance",
                    description: "Address the critical gaps to meet the deadline",
                    cost: 12000,
                    impact: DecisionImpact(performanceChange: 2, moraleChange: 0, budgetChange: -12000, reputationChange: 2, departmentSpecific: .engineering),
                    riskLevel: .medium,
                    impactVariance: 0.20
                ),
                DecisionOption(
                    title: "Request extension",
                    description: "Lobby for a timeline extension with other companies",
                    cost: 5000,
                    impact: DecisionImpact(performanceChange: -2, moraleChange: -3, budgetChange: -5000, reputationChange: -5),
                    riskLevel: .high,
                    impactVariance: 0.40
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct DataLocalizationTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .regulatory,
            title: "Data Localization Mandate",
            description: "The EU is enforcing strict data localization rules. All European student data must be stored on EU servers by next quarter.",
            options: [
                DecisionOption(
                    title: "Build EU data centers",
                    description: "Full infrastructure investment in European servers",
                    cost: 40000,
                    impact: DecisionImpact(performanceChange: 5, moraleChange: 2, budgetChange: -40000, reputationChange: 6),
                    riskLevel: .high,
                    impactVariance: 0.35
                ),
                DecisionOption(
                    title: "Partner with EU cloud provider",
                    description: "Use a local provider to host European data",
                    cost: 15000,
                    impact: DecisionImpact(performanceChange: 3, moraleChange: 1, budgetChange: -15000, reputationChange: 3),
                    riskLevel: .medium,
                    impactVariance: 0.22
                ),
                DecisionOption(
                    title: "Exit the EU market",
                    description: "Withdraw from Europe and focus on other regions",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: -4, moraleChange: -5, budgetChange: 5000, reputationChange: -6),
                    riskLevel: .medium,
                    impactVariance: 0.28
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct LicensingAuditTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .regulatory,
            title: "Licensing Audit",
            description: "A software audit reveals you may be using several open-source libraries in violation of their licenses. Legal action is possible.",
            options: [
                DecisionOption(
                    title: "Full license remediation",
                    description: "Audit all dependencies, replace non-compliant ones, and hire an open-source compliance officer",
                    cost: 20000,
                    impact: DecisionImpact(performanceChange: -3, moraleChange: -2, budgetChange: -20000, reputationChange: 5, departmentSpecific: .engineering),
                    riskLevel: .medium,
                    impactVariance: 0.20
                ),
                DecisionOption(
                    title: "Settle quietly",
                    description: "Pay licensing fees and fix the most critical violations",
                    cost: 12000,
                    impact: DecisionImpact(performanceChange: -1, moraleChange: -3, budgetChange: -12000, reputationChange: -2),
                    riskLevel: .medium,
                    impactVariance: 0.25
                ),
                DecisionOption(
                    title: "Rewrite affected components",
                    description: "Build replacements from scratch to avoid all licensing issues",
                    cost: 25000,
                    impact: DecisionImpact(performanceChange: -5, moraleChange: -6, budgetChange: -25000, reputationChange: 3, departmentSpecific: .engineering),
                    riskLevel: .high,
                    impactVariance: 0.38
                )
            ],
            quarter: company.quarter
        )
    }
}

// MARK: - Cross-Department Templates (added to existing categories)

private struct TechDebtConflictTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .technical,
            title: "Tech Debt Reckoning",
            description: "Engineering wants to freeze features for a quarter to address crippling tech debt. Sales warns this will cost 3 major deals. Both have valid points.",
            options: [
                DecisionOption(
                    title: "Full feature freeze",
                    description: "Stop all new features and fix the foundation",
                    cost: 5000,
                    impact: DecisionImpact(performanceChange: 10, moraleChange: -4, budgetChange: -5000, reputationChange: -3, departmentSpecific: .engineering),
                    riskLevel: .high,
                    impactVariance: 0.38
                ),
                DecisionOption(
                    title: "50/50 split",
                    description: "Dedicate half the team to debt, half to features",
                    cost: 3000,
                    impact: DecisionImpact(performanceChange: 4, moraleChange: 2, budgetChange: -3000, reputationChange: 0),
                    riskLevel: .medium,
                    impactVariance: 0.22
                ),
                DecisionOption(
                    title: "Features first",
                    description: "Close the deals now, address tech debt next quarter",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: -3, moraleChange: -6, budgetChange: 15000, reputationChange: 2),
                    riskLevel: .medium,
                    impactVariance: 0.28
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct DiversityInitiativeTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .hr,
            title: "Diversity & Inclusion Initiative",
            description: "Employee resource groups are requesting a formal D&I program with budget, dedicated staff, and public commitments. Some executives question the cost.",
            options: [
                DecisionOption(
                    title: "Comprehensive D&I program",
                    description: "Full program with dedicated team, training, and public commitment",
                    cost: 25000,
                    impact: DecisionImpact(performanceChange: 4, moraleChange: 10, budgetChange: -25000, reputationChange: 8),
                    riskLevel: .medium,
                    impactVariance: 0.22
                ),
                DecisionOption(
                    title: "Start with training",
                    description: "Begin with unconscious bias training and review hiring practices",
                    cost: 8000,
                    impact: DecisionImpact(performanceChange: 2, moraleChange: 5, budgetChange: -8000, reputationChange: 3),
                    riskLevel: .low,
                    impactVariance: 0.10
                ),
                DecisionOption(
                    title: "Form a committee",
                    description: "Create an advisory committee to study the issue and recommend actions",
                    cost: 2000,
                    impact: DecisionImpact(performanceChange: 0, moraleChange: -2, budgetChange: -2000, reputationChange: -1),
                    riskLevel: .low,
                    impactVariance: 0.08
                )
            ],
            quarter: company.quarter
        )
    }
}

private struct AcquisitionTargetTemplate: ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario {
        return Scenario(
            category: .opportunity,
            title: "Acquisition Target",
            description: "A smaller competitor with complementary technology is struggling financially. They could be acquired at a favorable price, but integration will be challenging.",
            options: [
                DecisionOption(
                    title: "Acquire and integrate",
                    description: "Buy the company and merge their technology into your platform",
                    cost: 45000,
                    impact: DecisionImpact(performanceChange: 12, moraleChange: -3, budgetChange: -45000, reputationChange: 6),
                    riskLevel: .high,
                    impactVariance: 0.45
                ),
                DecisionOption(
                    title: "Acquire team only",
                    description: "Hire their key engineers and let the company wind down",
                    cost: 20000,
                    impact: DecisionImpact(performanceChange: 6, moraleChange: 2, budgetChange: -20000, reputationChange: 2, departmentSpecific: .engineering),
                    riskLevel: .medium,
                    impactVariance: 0.25
                ),
                DecisionOption(
                    title: "Pass on the opportunity",
                    description: "Focus on organic growth instead",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 0, moraleChange: 0, budgetChange: 0, reputationChange: -1),
                    riskLevel: .low,
                    impactVariance: 0.05
                )
            ],
            quarter: company.quarter
        )
    }
}
