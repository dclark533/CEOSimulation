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
}