//
//  Tip_CalculatorSnapshotTests.swift
//  tip-calculatorTests
//
//  Created by Willy Hsu on 2025/4/7.
//

import Foundation
import SnapshotTesting
import XCTest
@testable import tip_calculator

final class Tip_CalculatorSnapshotTests: XCTestCase {
   
    private var screenWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    func testLogoView(){
        let size = CGSize(width: screenWidth, height: 48)
        let view = LogoView()
        assertSnapshot(matching: view, as: .image(size: size))
    }

    func testInitialResultView(){
        let size = CGSize(width: screenWidth, height: 224)
        let view = ResultView()
        assertSnapshot(matching: view, as: .image(size: size))
    }

    func testResultView(){
        let size = CGSize(width: screenWidth, height: 224)
        let result = Result(amountPerPerson: 100.25,
                            totalBill: 45,
                            totalTip: 60)
        let view = ResultView()
        view.configure(result: result)
        assertSnapshot(matching: view, as: .image(size: size))
    }

    func testInitialBillInputView(){
        let size = CGSize(width: screenWidth, height: 56)
        let view = BillInputView()
        assertSnapshot(matching: view, as: .image(size: size))
    }

    func testBillInputView(){
        let size = CGSize(width: screenWidth, height: 56)
        let view = BillInputView()
        let textField = view.allSubViewsOf(type: UITextField.self).first
        textField?.text = "500"
        assertSnapshot(matching: view, as: .image(size: size))
    }

    func testInitialTipInputView(){
        let size = CGSize(width: screenWidth, height: 56+56+15)
        let view = TipInputView()
        assertSnapshot(matching: view, as: .image(size: size))
    }

    func testTipInputView(){
        let size = CGSize(width: screenWidth, height: 56+56+15)
        let view = TipInputView()
        let button = view.allSubViewsOf(type: UIButton.self).first
        button?.sendActions(for: .touchUpInside)
        assertSnapshot(matching: view, as: .image(size: size))
    }

    func testInitialSplitInputView(){
        let size = CGSize(width: screenWidth, height: 56)
        let view = SplitInputView()
        assertSnapshot(matching: view, as: .image(size: size))
    }

    func testSplitInputView(){
        let size = CGSize(width: screenWidth, height: 56)
        let view = TipInputView()
        let button = view.allSubViewsOf(type: UIButton.self).first
        button?.sendActions(for: .touchUpInside)
        assertSnapshot(matching: view, as: .image(size: size))
    }
}

extension UIView {

  func subViews<T : UIView>(type : T.Type) -> [T]{
      var all = [T]()
      for view in self.subviews {
          if let aView = view as? T{
              all.append(aView)
          }
      }
      return all
  }


      func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
          var all = [T]()
          func getSubview(view: UIView) {
              if let aView = view as? T{
              all.append(aView)
              }
              guard view.subviews.count>0 else { return }
              view.subviews.forEach{ getSubview(view: $0) }
          }
          getSubview(view: self)
          return all
      }
  }
