//
//  ThemeFont.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/28.
//

import Foundation
import UIKit

struct ThemeFont{
    
    static func regular(Ofsize size: CGFloat) -> UIFont {
        return UIFont(name:"AvenirNext-Regular",size:size) ?? .systemFont(ofSize: size)
    }
    
    static func bold(Ofsize size: CGFloat) -> UIFont {
        return UIFont(name:"AvenirNext-Bold",size:size) ?? .systemFont(ofSize: size)
    }
    
    static func demiBold(Ofsize size: CGFloat) -> UIFont {
        return UIFont(name:"AvenirNext-DemiBold",size:size) ?? .systemFont(ofSize: size)
    }
}
