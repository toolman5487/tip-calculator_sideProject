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
        //Given
        let size = CGSize(width: screenWidth, height: 48)
        //Then
        let view = LogoView()
        //When
        assertSnapshot(matching: view, as: .image(size: size))
    }
    
    func testInitialResultView(){
        //Given
        let size = CGSize(width: screenWidth, height: 224)
        //Then
        let view = ResultView()
        //When
        assertSnapshot(matching: view, as: .image(size: size))
    }
    
    func testResultView(){
        //Given
        let size = CGSize(width: screenWidth, height: 224)
        let result = Result(amountPerPerson: 100.25,
                            totalBill: 45,
                            totalTip: 60)
        //Then
        let view = ResultView()
        view.configure(result: result)
        //When
        assertSnapshot(matching: view, as: .image(size: size))
    }
    
    func testInitialBillInputView(){
        //Given
        let size = CGSize(width: screenWidth, height: 56)
        //Then
        let view = BillInputView()
        //When
        assertSnapshot(matching: view, as: .image(size: size))
    }
    
    func testBillInputView(){
        //Given
        let size = CGSize(width: screenWidth, height: 56)
        
        //Then
        let view = BillInputView()
        let textField = view.allSubViewsOf(type: UITextField.self).first
        textField?.text = "500"
        
        //When
        assertSnapshot(matching: view, as: .image(size: size))
    }
    
    func testInitialTipInputView(){
        //Given
        let size = CGSize(width: screenWidth, height: 56+56+15)
        //Then
        let view = TipInputView()
        //When
        assertSnapshot(matching: view, as: .image(size: size))
    }
    
    func testTipInputView(){
        //Given
        let size = CGSize(width: screenWidth, height: 56+56+15)
        
        //Then
        let view = TipInputView()
        let button = view.allSubViewsOf(type: UIButton.self).first
        button?.sendActions(for: .touchUpInside)
        
        //When
        assertSnapshot(matching: view, as: .image(size: size))
    }
    
    func testInitialSplitInputView(){
        //Given
        let size = CGSize(width: screenWidth, height: 56)
        //Then
        let view = SplitInputView()
        //When
        assertSnapshot(matching: view, as: .image(size: size))
    }
    
    func testSplitInputView(){
        //Given
        let size = CGSize(width: screenWidth, height: 56)
        
        //Then
        let view = TipInputView()
        let button = view.allSubViewsOf(type: UIButton.self).first
        button?.sendActions(for: .touchUpInside)
        
        //When
        assertSnapshot(matching: view, as: .image(size: size))
    }
}

extension UIView {

  /** This is the function to get subViews of a view of a particular type
*/
  func subViews<T : UIView>(type : T.Type) -> [T]{
      var all = [T]()
      for view in self.subviews {
          if let aView = view as? T{
              all.append(aView)
          }
      }
      return all
  }


/** This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T */
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
