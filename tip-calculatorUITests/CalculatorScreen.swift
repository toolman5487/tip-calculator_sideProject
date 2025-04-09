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
    
    enum Tip{
        case tenPercent
        case fifteenPercent
        case twentyPercent
        case custom(value:Int)
    }
    
    //LogoView
    var logoView:XCUIElement{
        return app.otherElements[ScreenIdentifier1.logoView.logoView.rawValue]
    }
    
    
    //ResultView
    var totalAmountPerPersonValueLabel:XCUIElement{
        return app.staticTexts[ScreenIdentifier1.ResultView.totalAmountPerPersonValueLabel.rawValue]
    }
    
    var totalBillValueLabel:XCUIElement{
        return app.staticTexts[ScreenIdentifier1.ResultView.totalBillValueLabel.rawValue]
    }
    
    var totalTipValueLabel:XCUIElement{
        return app.staticTexts[ScreenIdentifier1.ResultView.totalTipValueLabel.rawValue]
    }
    
    //BillInputView
    var billInputViewTextField:XCUIElement{
        app.textFields[ScreenIdentifier1.BillInputView.textField.rawValue]
    }
    
    //TipInputView
    var tenPercentTipInputView:XCUIElement{
        app.buttons[ScreenIdentifier1.TipInputView.tenPercentButton.rawValue]
    }
    
    var fifteenPercentTipInputView:XCUIElement{
        app.buttons[ScreenIdentifier1.TipInputView.fifteenPercentButton.rawValue]
    }
    
    var twentyPercentTipInputView:XCUIElement{
        app.buttons[ScreenIdentifier1.TipInputView.twentyPercentButton.rawValue]
    }
    
    var customTipButton:XCUIElement{
        app.buttons[ScreenIdentifier1.TipInputView.customTipButton.rawValue]
    }
    
    var customTipAlertTextField:XCUIElement{
        app.textFields[ScreenIdentifier1.TipInputView.customTipAlertTextField.rawValue]
    }
    
    //SplitInputView
    var decrementButton:XCUIElement{
        app.buttons[ScreenIdentifier1.SplitInputView.decreaseButton.rawValue]
    }
    
    var incrementButton:XCUIElement{
        app.buttons[ScreenIdentifier1.SplitInputView.increaseButton.rawValue]
    }
    
    var splitValueLabel:XCUIElement{
        app.staticTexts[ScreenIdentifier1.SplitInputView.quantityValueLabel.rawValue]
    }
    
    //Actions
    func enterBill(amount:Double){
        billInputViewTextField.tap()
        billInputViewTextField.typeText("\(amount)\n")
    }
    
    func selectTip(tip:Tip){
        switch tip {
        case .tenPercent:
            tenPercentTipInputView.tap()
        case .fifteenPercent:
            fifteenPercentTipInputView.tap()
        case .twentyPercent:
            twentyPercentTipInputView.tap()
        case .custom(value: let value):
            customTipButton.tap()
            XCTAssertTrue(customTipAlertTextField.waitForExistence(timeout: 1.0))
            customTipAlertTextField.typeText("\(value)\n")
        }
    }
    
    
    init(app: XCUIApplication) {
        self.app = app
    }
}
