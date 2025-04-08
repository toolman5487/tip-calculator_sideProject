//
//  ScreenIdentifier1.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/4/8.
//

import Foundation

enum ScreenIdentifier1{
    
    enum logoView:String{
        case logoView
    }
    
    enum ResultView: String{
        case totalAmountPerPersonValueLabel
        case totalBillValueLabel
        case totalTipValueLabel
    }
    
    enum BillInputView: String{
        case textField
    }
    
    enum TipInputView: String{
        case tenPercentButton
        case fifteenPercentButton
        case twentyPercentButton
        case customTipButton
    }
    
    enum SplitInputView: String{
        case decreaseButton
        case increaseButton
        case quantityValueLabel
    }
    
    
}
