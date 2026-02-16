import XCTest
@testable import CEOSimulationCore

@MainActor
final class MarketEventTests: XCTestCase {
    func testPoolNotEmpty() {
        XCTAssertFalse(MarketEventPool.events.isEmpty)
        XCTAssertEqual(MarketEventPool.events.count, 10)
    }

    func testValidDurations() {
        for event in MarketEventPool.events {
            XCTAssertGreaterThanOrEqual(event.duration, GameConstants.marketEventMinDuration, "\(event.name) has invalid duration")
            XCTAssertLessThanOrEqual(event.duration, GameConstants.marketEventMaxDuration, "\(event.name) has invalid duration")
        }
    }

    func testAllEventsHaveNames() {
        for event in MarketEventPool.events {
            XCTAssertFalse(event.name.isEmpty)
            XCTAssertFalse(event.description.isEmpty)
            XCTAssertFalse(event.icon.isEmpty)
        }
    }

    func testModifierApplication() {
        let recession = MarketEventPool.events.first { $0.name == "Economic Recession" }!
        XCTAssertLessThan(recession.modifier.budgetDrain, 0)
        XCTAssertLessThan(recession.modifier.performanceChange, 0)
        XCTAssertLessThan(recession.modifier.moraleChange, 0)
    }

    func testPositiveEvent() {
        let boom = MarketEventPool.events.first { $0.name == "Tech Boom" }!
        XCTAssertGreaterThan(boom.modifier.performanceChange, 0)
        XCTAssertGreaterThan(boom.modifier.moraleChange, 0)
        XCTAssertGreaterThan(boom.modifier.reputationChange, 0)
    }

    func testWeightAdjustmentsReasonable() {
        for event in MarketEventPool.events {
            for (_, weight) in event.categoryWeightAdjustments {
                XCTAssertGreaterThan(weight, 0, "\(event.name) has non-positive weight adjustment")
                XCTAssertLessThanOrEqual(weight, 0.5, "\(event.name) has unreasonably high weight adjustment")
            }
        }
    }

    func testRandomEventReturnsNilOrEvent() {
        // Call many times — some should return nil (60% chance), some an event (40%)
        var nilCount = 0
        var eventCount = 0
        for _ in 0..<100 {
            if MarketEventPool.randomEvent() == nil {
                nilCount += 1
            } else {
                eventCount += 1
            }
        }
        // With 100 trials at 40%, extremely unlikely to get 0 or 100 events
        XCTAssertGreaterThan(eventCount, 0, "Should get at least one event in 100 tries")
        XCTAssertGreaterThan(nilCount, 0, "Should get at least one nil in 100 tries")
    }
}
