//
//  TeamBoardTests.swift
//  TeamBoardTests
//
//  Created by Fabio Innocente on 4/4/16.
//  Copyright © 2016 MC. All rights reserved.
//

import XCTest
@testable import TeamBoard

class TeamBoardTests: XCTestCase {
    
    var trelloManagerTest = TrelloManager()
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testGetBoardsByOrganization(){
        var expectation : XCTestExpectation? = expectationWithDescription(">>>>> Request error <<<<<")
        TrelloManager.sharedInstance.getMember { (me, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(me)
            TrelloManager.sharedInstance.getOrganizations({ (organizations, error) in
                XCTAssertNil(error)
                XCTAssertNotNil(organizations)
                for organization in organizations! {
                    TrelloManager.sharedInstance.getBoards(organization.id!, completionHandler: { (boards, error) in
                        XCTAssertNil(error)
                        XCTAssertNotNil(boards)
                        var boardRequestCounter = 0
                        for board in boards! {
                            TrelloManager.sharedInstance.getBoard(board.id!, completionHandler: { (board, error) in
                                XCTAssertNil(error)
                                XCTAssertNotNil(board)
                                XCTAssertGreaterThan(board!.members!.count, 0)
                                boardRequestCounter += 1
                                if boardRequestCounter == boards!.count {
                                    expectation?.fulfill()
                                    expectation = nil
                                }
                            })
                        }
                    })
                }
            })
        }
        waitForExpectationsWithTimeout(15, handler: nil)
    }
 
    func testGetCardsAndMatchPointsWithBoardMembers(){
        var expectation : XCTestExpectation? = expectationWithDescription(">>>>> Request error <<<<<")
        TrelloManager.sharedInstance.getMember { (me, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(me)
            TrelloManager.sharedInstance.getOrganizations({ (organizations, error) in
                XCTAssertNil(error)
                XCTAssertNotNil(organizations)
                var boardsRequestCounter = 0
                for organization in organizations! {
                    TrelloManager.sharedInstance.getBoards(organization.id!, completionHandler: { (boards, error) in
                        XCTAssertNil(error)
                        XCTAssertNotNil(boards)
                        boardsRequestCounter += 1
                        var cardsRequestCounter = 0
                        for board in boards! {
                            TrelloManager.sharedInstance.getCardsFromBoard(board.id!, completionHandler: { (cards, error) in
                                XCTAssertNil(error)
                                XCTAssertNotNil(cards)
                                cardsRequestCounter += 1
                                XCTAssertNotNil(board.members)
                                let cardsWithPoints = cards!.filter({ (card) -> Bool in
                                    return card.points > 0
                                })
                                
                                if cardsWithPoints.count > 0 {
                                    board.matchPointsWithMembers(cards!)
                                    let membersWithPoints = board.members!.filter({ (member) -> Bool in
                                        return member.points > 0
                                    })
                                    XCTAssertGreaterThan(membersWithPoints.count, 0)
                                }
                                
                                if cardsRequestCounter == boards!.count && boardsRequestCounter == organizations!.count {
                                    expectation?.fulfill()
                                    expectation = nil
                                }
                            })
                        }
                    })
                }
            })
        }
        waitForExpectationsWithTimeout(20, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
    }
    
}