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
    
    func testParser(){
//        let boards = TBOJsonParser.getBoards()
//        XCTAssertNotNil(boards?.first)
//        print(">>>>>> \(boards?.first?.name)")
//        
//        let members = TBOJsonParser.getMembersFromBoard()
//        XCTAssertNotNil(members?.first)
//        print("<<<<< \(members?.first?.username)")
//        
//        let cards = TBOJsonParser.getCards()
//        XCTAssertNotNil(cards?.first)
//        print("##### \(cards?.first?.name)")
        let expectation = expectationWithDescription(">>>>> Request error <<<<<")
        TBOJsonParser.getBoards("4eea4ffc91e31d1746000046") { (boards, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(boards)
//            XCTAssertGreaterThan(boards!.count, 0)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(15, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}