import XCTest
@testable import CEOSimulationCore

@MainActor
final class GameControllerTests: XCTestCase {
    var gameController: GameController!
    
    override func setUp() {
        super.setUp()
        gameController = GameController()
    }
    
    override func tearDown() {
        gameController = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertFalse(gameController.isGameActive)
        XCTAssertNil(gameController.currentScenario)
        XCTAssertEqual(gameController.company.quarter, 1)
        XCTAssertEqual(gameController.company.departments.count, 5)
    }
    
    func testStartNewGame() {
        gameController.startNewGame()
        
        XCTAssertTrue(gameController.isGameActive)
        XCTAssertEqual(gameController.company.budget, 100000)
        XCTAssertEqual(gameController.company.reputation, 50)
        XCTAssertEqual(gameController.company.quarter, 1)
    }
    
    func testCompanyHasFiveDepartments() {
        let expectedDepartments: Set<DepartmentType> = [.sales, .marketing, .engineering, .hr, .finance]
        let actualDepartments = Set(gameController.company.departments.map(\.type))
        
        XCTAssertEqual(actualDepartments, expectedDepartments)
    }
    
    func testScoreCalculation() {
        gameController.startNewGame()
        let initialScore = gameController.getCurrentScore()

        XCTAssertGreaterThan(initialScore, 0)
    }

    func testMarketEventInitiallyNil() {
        gameController.startNewGame()
        XCTAssertNil(gameController.currentMarketEvent)
        XCTAssertEqual(gameController.marketEventQuartersRemaining, 0)
    }

    func testStartNewGameResetsMarketEvent() {
        gameController.startNewGame()
        // Manually set a market event to simulate one being active
        gameController.currentMarketEvent = MarketEventPool.events.first
        gameController.marketEventQuartersRemaining = 2

        gameController.startNewGame()
        XCTAssertNil(gameController.currentMarketEvent)
        XCTAssertEqual(gameController.marketEventQuartersRemaining, 0)
    }

    func testScoreBreakdown() {
        gameController.startNewGame()
        let breakdown = gameController.getScoreBreakdown()
        XCTAssertGreaterThanOrEqual(breakdown.baseScore, 0)
        XCTAssertGreaterThanOrEqual(breakdown.longevityBonus, 0)
        XCTAssertEqual(breakdown.totalScore, gameController.getCurrentScore())
    }

    func testMakeDecisionAdvancesGame() {
        gameController.startNewGame()
        XCTAssertNotNil(gameController.currentScenario)
        let initialHistoryCount = gameController.scenarioHistory.count

        if gameController.currentScenario != nil {
            gameController.makeDecision(0)
            XCTAssertEqual(gameController.scenarioHistory.count, initialHistoryCount + 1)
        }
    }
}