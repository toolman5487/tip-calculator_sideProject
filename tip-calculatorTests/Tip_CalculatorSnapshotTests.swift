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
    
    func testInitialBillInputView(){
        //Given
        let size = CGSize(width: screenWidth, height: 56)
        //Then
        let view = BillInputView()
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
    
    func testInitialSplitInputView(){
        //Given
        let size = CGSize(width: screenWidth, height: 56)
        //Then
        let view = SplitInputView()
        //When
        assertSnapshot(matching: view, as: .image(size: size))
    }
}
