//
//  tip_calculatorUITests.swift
//  tip-calculatorUITests
//
//  Created by Willy Hsu on 2025/3/27.
//

import XCTest

final class tip_calculatorUITests: XCTestCase {
    
    private var app: XCUIApplication!
    
    private var screen:CalculatorScreen{
        CalculatorScreen(app: app)
    }
    
    override func setUp() {
        super.setUp()
        app = .init()
        app.launch()
    }
    
    func testResultDefaultValues() {
        XCTAssertEqual(screen.totalAmountPerPersonValueLabel.label, "$0")
        XCTAssertEqual(screen.totalBillValueLabel.label, "$0")
        XCTAssertEqual(screen.totalTipValueLabel.label, "$0")
    }
    
    override func tearDown() {
        super.tearDown()
        app = nil
    }
}
