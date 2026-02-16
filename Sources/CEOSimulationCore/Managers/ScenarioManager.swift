import Foundation

@MainActor
public class ScenarioManager {
    private let scenarioTemplates: [ScenarioCategory: [ScenarioTemplate]]
    
    public init() {
        self.scenarioTemplates = Self.createScenarioTemplates()
    }
    
    public func generateScenario(for company: Company) -> Scenario {
        let category = selectScenarioCategory(for: company)
        let templates = scenarioTemplates[category] ?? []
        
        guard !templates.isEmpty else {
            return createFallbackScenario(company: company)
        }
        
        let template = templates.randomElement()!
        return template.createScenario(for: company)
    }
    
    private func selectScenarioCategory(for company: Company) -> ScenarioCategory {
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
                    impact: DecisionImpact(performanceChange: 10, budgetChange: -5000)
                ),
                DecisionOption(
                    title: "Basic maintenance",
                    description: "Essential updates only",
                    cost: 2000,
                    impact: DecisionImpact(performanceChange: 5, budgetChange: -2000)
                ),
                DecisionOption(
                    title: "Delay maintenance",
                    description: "Postpone maintenance to save money",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: -5, budgetChange: 0)
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
                AIInvestmentTemplate()
            ],
            .marketing: [
                NegativeReviewTemplate(),
                CompetitorTemplate(),
                BrandingTemplate()
            ],
            .hr: [
                TalentRetentionTemplate(),
                WorkCultureTemplate(),
                RecruitmentTemplate()
            ],
            .opportunity: [
                MarketExpansionTemplate(),
                PartnershipTemplate(),
                ProductLaunchTemplate()
            ]
        ]
    }
}

@MainActor
private protocol ScenarioTemplate {
    func createScenario(for company: Company) -> Scenario
}

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
                    impact: DecisionImpact(performanceChange: -5, moraleChange: -10, budgetChange: company.budget * 0.1, reputationChange: -2)
                ),
                DecisionOption(
                    title: "Seek emergency funding",
                    description: "Apply for a business loan",
                    cost: 1000,
                    impact: DecisionImpact(performanceChange: 0, moraleChange: -2, budgetChange: 25000, reputationChange: -1)
                ),
                DecisionOption(
                    title: "Delay payments",
                    description: "Negotiate extended payment terms",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: -2, moraleChange: -5, budgetChange: 5000, reputationChange: -5)
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
                    impact: DecisionImpact(performanceChange: 15, moraleChange: 10, budgetChange: -35000, reputationChange: 8, departmentSpecific: .engineering)
                ),
                DecisionOption(
                    title: "Gradual integration",
                    description: "Steady improvement, moderate cost",
                    cost: 15000,
                    impact: DecisionImpact(performanceChange: 8, moraleChange: 5, budgetChange: -15000, reputationChange: 3, departmentSpecific: .engineering)
                ),
                DecisionOption(
                    title: "Wait and watch",
                    description: "No cost, but risk falling behind",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: -3, moraleChange: -2, budgetChange: 0, reputationChange: -1)
                )
            ],
            quarter: company.quarter
        )
    }
}

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
                    impact: DecisionImpact(performanceChange: 5, moraleChange: 0, budgetChange: -15000, reputationChange: 12, departmentSpecific: .marketing)
                ),
                DecisionOption(
                    title: "Influencer counter-narrative",
                    description: "Partner with influencers to share positive stories",
                    cost: 8000,
                    impact: DecisionImpact(performanceChange: 2, moraleChange: 0, budgetChange: -8000, reputationChange: 7, departmentSpecific: .marketing)
                ),
                DecisionOption(
                    title: "Wait for storm to pass",
                    description: "Let the controversy die down naturally",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: -5, moraleChange: -5, budgetChange: 0, reputationChange: -8)
                )
            ],
            quarter: company.quarter
        )
    }
}

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
                    impact: DecisionImpact(performanceChange: 12, moraleChange: 5, budgetChange: -25000, reputationChange: 3, departmentSpecific: .engineering)
                ),
                DecisionOption(
                    title: "Standard upgrade",
                    description: "Adequate improvements for current needs",
                    cost: 12000,
                    impact: DecisionImpact(performanceChange: 7, moraleChange: 2, budgetChange: -12000, reputationChange: 1, departmentSpecific: .engineering)
                ),
                DecisionOption(
                    title: "Minimal patches",
                    description: "Temporary fixes to buy time",
                    cost: 3000,
                    impact: DecisionImpact(performanceChange: 2, moraleChange: -2, budgetChange: -3000, reputationChange: -1, departmentSpecific: .engineering)
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
                    impact: DecisionImpact(performanceChange: 2, moraleChange: 3, budgetChange: company.budget * 0.2, reputationChange: 2)
                ),
                DecisionOption(
                    title: "Counter-offer 10%",
                    description: "Negotiate a smaller discount",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 1, moraleChange: 1, budgetChange: company.budget * 0.15, reputationChange: 1)
                ),
                DecisionOption(
                    title: "Decline politely",
                    description: "Maintain full pricing structure",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 0, moraleChange: 0, budgetChange: 0, reputationChange: 0)
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
                    impact: DecisionImpact(performanceChange: 8, moraleChange: 5, budgetChange: -20000, reputationChange: 5, departmentSpecific: .engineering)
                ),
                DecisionOption(
                    title: "Patch critical issues",
                    description: "Address the most urgent vulnerabilities",
                    cost: 8000,
                    impact: DecisionImpact(performanceChange: 4, moraleChange: 2, budgetChange: -8000, reputationChange: 2, departmentSpecific: .engineering)
                ),
                DecisionOption(
                    title: "Monitor and assess",
                    description: "Keep watching without immediate action",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: -3, moraleChange: -5, budgetChange: 0, reputationChange: -10)
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
                    impact: DecisionImpact(performanceChange: 3, moraleChange: -2, budgetChange: -18000, reputationChange: 4, departmentSpecific: .marketing)
                ),
                DecisionOption(
                    title: "Feature differentiation",
                    description: "Highlight unique features and value",
                    cost: 10000,
                    impact: DecisionImpact(performanceChange: 5, moraleChange: 3, budgetChange: -10000, reputationChange: 3, departmentSpecific: .marketing)
                ),
                DecisionOption(
                    title: "Focus on retention",
                    description: "Strengthen relationships with existing clients",
                    cost: 5000,
                    impact: DecisionImpact(performanceChange: 2, moraleChange: 2, budgetChange: -5000, reputationChange: 1)
                )
            ],
            quarter: company.quarter
        )
    }
}

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
                    impact: DecisionImpact(performanceChange: 8, moraleChange: 15, budgetChange: -30000, reputationChange: 2, departmentSpecific: .hr)
                ),
                DecisionOption(
                    title: "Enhanced benefits package",
                    description: "Improve benefits without salary changes",
                    cost: 12000,
                    impact: DecisionImpact(performanceChange: 4, moraleChange: 8, budgetChange: -12000, reputationChange: 1, departmentSpecific: .hr)
                ),
                DecisionOption(
                    title: "Flexible work arrangements",
                    description: "Offer remote work and flexible schedules",
                    cost: 2000,
                    impact: DecisionImpact(performanceChange: 2, moraleChange: 6, budgetChange: -2000, reputationChange: 1, departmentSpecific: .hr)
                )
            ],
            quarter: company.quarter
        )
    }
}

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
                    impact: DecisionImpact(performanceChange: 12, moraleChange: 8, budgetChange: -45000, reputationChange: 6)
                ),
                DecisionOption(
                    title: "Pilot program",
                    description: "Start small with a limited market test",
                    cost: 15000,
                    impact: DecisionImpact(performanceChange: 5, moraleChange: 3, budgetChange: -15000, reputationChange: 2)
                ),
                DecisionOption(
                    title: "Decline opportunity",
                    description: "Focus on domestic market for now",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 0, moraleChange: -1, budgetChange: 0, reputationChange: 0)
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
                    impact: DecisionImpact(performanceChange: 10, moraleChange: 5, budgetChange: 100000, reputationChange: 8)
                ),
                DecisionOption(
                    title: "Negotiate terms",
                    description: "Smaller investment with better equity terms",
                    cost: 5000,
                    impact: DecisionImpact(performanceChange: 6, moraleChange: 2, budgetChange: 50000, reputationChange: 4)
                ),
                DecisionOption(
                    title: "Decline investment",
                    description: "Maintain full company control",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 0, moraleChange: 1, budgetChange: 0, reputationChange: 1)
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
                    impact: DecisionImpact(performanceChange: 6, moraleChange: 3, budgetChange: -25000, reputationChange: 8, departmentSpecific: .marketing)
                ),
                DecisionOption(
                    title: "Gradual refresh",
                    description: "Incremental updates to brand elements",
                    cost: 10000,
                    impact: DecisionImpact(performanceChange: 3, moraleChange: 2, budgetChange: -10000, reputationChange: 3, departmentSpecific: .marketing)
                ),
                DecisionOption(
                    title: "Keep current brand",
                    description: "Maintain existing brand identity",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 0, moraleChange: 0, budgetChange: 0, reputationChange: -1)
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
                    impact: DecisionImpact(performanceChange: 8, moraleChange: 12, budgetChange: -20000, reputationChange: 3, departmentSpecific: .hr)
                ),
                DecisionOption(
                    title: "Targeted improvements",
                    description: "Address specific concerns with focused initiatives",
                    cost: 8000,
                    impact: DecisionImpact(performanceChange: 4, moraleChange: 6, budgetChange: -8000, reputationChange: 1, departmentSpecific: .hr)
                ),
                DecisionOption(
                    title: "Acknowledge concerns",
                    description: "Thank employees for feedback without major changes",
                    cost: 1000,
                    impact: DecisionImpact(performanceChange: 0, moraleChange: -2, budgetChange: -1000, reputationChange: 0, departmentSpecific: .hr)
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
                    impact: DecisionImpact(performanceChange: 12, moraleChange: 5, budgetChange: -35000, reputationChange: 2, departmentSpecific: .hr)
                ),
                DecisionOption(
                    title: "Standard hiring",
                    description: "Hire qualified candidates at market rates",
                    cost: 18000,
                    impact: DecisionImpact(performanceChange: 6, moraleChange: 2, budgetChange: -18000, reputationChange: 1, departmentSpecific: .hr)
                ),
                DecisionOption(
                    title: "Internal promotion",
                    description: "Promote existing employees to fill roles",
                    cost: 5000,
                    impact: DecisionImpact(performanceChange: 3, moraleChange: 8, budgetChange: -5000, reputationChange: 0)
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
                    impact: DecisionImpact(performanceChange: 15, moraleChange: 5, budgetChange: -15000, reputationChange: 10)
                ),
                DecisionOption(
                    title: "Non-exclusive partnership",
                    description: "Flexible arrangement allowing other partnerships",
                    cost: 8000,
                    impact: DecisionImpact(performanceChange: 8, moraleChange: 3, budgetChange: -8000, reputationChange: 5)
                ),
                DecisionOption(
                    title: "Decline partnership",
                    description: "Maintain independence and develop own content",
                    cost: 0,
                    impact: DecisionImpact(performanceChange: 2, moraleChange: 0, budgetChange: 0, reputationChange: 0)
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
                    impact: DecisionImpact(performanceChange: 10, moraleChange: 6, budgetChange: -22000, reputationChange: 8)
                ),
                DecisionOption(
                    title: "Soft launch to beta users",
                    description: "Release to select customers for feedback",
                    cost: 5000,
                    impact: DecisionImpact(performanceChange: 5, moraleChange: 3, budgetChange: -5000, reputationChange: 3)
                ),
                DecisionOption(
                    title: "Internal testing only",
                    description: "Continue testing before any customer release",
                    cost: 2000,
                    impact: DecisionImpact(performanceChange: 2, moraleChange: 1, budgetChange: -2000, reputationChange: 0)
                )
            ],
            quarter: company.quarter
        )
    }
}