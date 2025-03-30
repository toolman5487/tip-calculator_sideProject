//
//  Tip.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/29.
//

import Foundation

enum Tip{
    case none
    case tenPercent
    case fifteenPercent
    case twentyPercent
    case custom(value: Int)
    
    var stringValue:String{
        switch self {
        case .none:
            return  ""
        case .tenPercent:
            return "10%"
        case .fifteenPercent:
            return "15%"
        case .twentyPercent:
            return "20%"
        case .custom(let value):
            return String(value)
        }
    }
}
