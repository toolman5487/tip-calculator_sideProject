//
//  UIResponder+Extension.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/30.
//

import Foundation
import UIKit

extension UIResponder{
    var parentViewController:UIViewController?{
        return next as? UIViewController ?? next?.parentViewController
    }
}
