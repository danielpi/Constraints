//
//  Partial_Differential_ExplorerTests.swift
//  Partial Differential ExplorerTests
//
//  Created by Daniel Pink on 20/01/2016.
//  Copyright © 2016 Daniel Pink. All rights reserved.
//

import XCTest
@testable import Partial_Differential_Explorer

class Partial_Differential_ExplorerTests: XCTestCase {
    let equation1: Expr = ((2 * "x") + (3 * "y")) * ("x" + (-1 * "y")) ==== 2
    let equation2: Expr = ((3 * "x") + "y") ==== 5
    
    var system: Expr = 1
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        system = costFunction([equation1, equation2])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let expression1 = Expr.Sum(.Variable("x"), .Constant(1))
        
        XCTAssertEqual(eval(expression1, ["x": 1]), 2.0, "1 + 1 should equal 2")
    }
    
    func testSolve1() {
        let journey = solve(system, initial: ["x": 0.0, "y": 0.0])
        
        XCTAssertGreaterThan(journey.count, 0)
        XCTAssertLessThan(journey.count, 50)
        
        XCTAssertEqualWithAccuracy(journey.last!["x"]!, 1.33884, accuracy: 1e-4)
        XCTAssertEqualWithAccuracy(journey.last!["y"]!, 0.983481, accuracy: 1e-4)
    }
    
    func testSolve2() {
        let journey = solve(system, initial: ["x": 2.0, "y": -2.0])
        
        XCTAssertGreaterThan(journey.count, 0)
        XCTAssertLessThan(journey.count, 150)
        
        XCTAssertEqualWithAccuracy(journey.last!["x"]!, 2.05402, accuracy: 1e-4)
        XCTAssertEqualWithAccuracy(journey.last!["y"]!, -1.16205, accuracy: 1e-4)
    }
    
    func testScatterSolvePerformanceExample() {
        // This is an example of a performance test case.
        
        let bottomLeft = Point(x:0, y:-2)
        let topRight = Point(x: 4, y:2)
        
        self.measureBlock {
            // Put the code you want to measure the time of here.
            scatterSolve(self.system, from: bottomLeft, to: topRight, pointCount: 10)
        }
    }
    
}
