//
//  CalculatorScreen.swift
//  tip-calculatorUITests
//
//  Created by Willy Hsu on 2025/4/8.
//

import Foundation
import XCTest

class CalculatorScreen {
    
    private var app: XCUIApplication
    
    var totalAmountPerPersonValueLabel:XCUIElement{
        return app.staticTexts[ScreenIdentifier1.ResultView.totalAmountPerPersonValueLabel.rawValue]
    }
    
    var totalBillValueLabel:XCUIElement{
        return app.staticTexts[ScreenIdentifier1.ResultView.totalBillValueLabel.rawValue]
    }
    
    var totalTipValueLabel:XCUIElement{
        return app.staticTexts[ScreenIdentifier1.ResultView.totalTipValueLabel.rawValue]
    }
    
    init(app: XCUIApplication) {
        self.app = app
    }
}
