//
//  tip_calculatorTests.swift
//  tip-calculatorTests
//
//  Created by Willy Hsu on 2025/3/27.
//

import XCTest
import Combine

@testable import tip_calculator

final class tip_calculatorTests: XCTestCase {
    
    private var sut: CalculatorVM! //sut = System under Test
    private var cancellables:Set<AnyCancellable>!
    private let logoViewTapSubject = PassthroughSubject<Void, Never>()
        
    override func setUp() {
        sut = .init()
        cancellables = .init()
        super.setUp()
    }
    
    func buildInput(bill:Double, tip:Tip, split: Int) -> CalculatorVM.Input {
        return .init(billPublisher: Just(bill).eraseToAnyPublisher(),
                     tipPublisher: Just(tip).eraseToAnyPublisher(),
                     splitPublisher: Just(split).eraseToAnyPublisher(),
                     logoViewTapPulisher: logoViewTapSubject.eraseToAnyPublisher())
    }
    
    func testResultWithoutTipFor_1Person(){
        let bill:Double = 100.0
        let tip:Tip = .none
        let split:Int = 1
        let input = buildInput(bill: bill, tip: tip, split: split)
        let output = sut.tranform(input: input)
        output.updateViewPublisher.sink { result in
            XCTAssertEqual(result.amountPerPerson, 100.0)
            XCTAssertEqual(result.totalBill, 100)
            XCTAssertEqual(result.totalTip, 0)
        }.store(in: &cancellables)
    }
    
    func testResultWithoutTipFor_2Person(){
        let bill:Double = 100
        let tip:Tip = .none
        let split:Int = 2
        let input = buildInput(bill: bill, tip: tip, split: split)
        let output = sut.tranform(input: input)
        output.updateViewPublisher.sink { result in
            XCTAssertEqual(result.amountPerPerson, 50.0)
            XCTAssertEqual(result.totalBill, 100)
            XCTAssertEqual(result.totalTip, 0)
        }.store(in: &cancellables)
    }
    
    func testResultWith_10PercentTip_For_2Person(){
        let bill:Double = 100
        let tip:Tip = .tenPercent
        let split:Int = 2
        let input = buildInput(bill: bill, tip: tip, split: split)
        let output = sut.tranform(input: input)
        output.updateViewPublisher.sink { result in
            XCTAssertEqual(result.amountPerPerson, 55.0)
            XCTAssertEqual(result.totalBill, 110)
            XCTAssertEqual(result.totalTip, 10)
        }.store(in: &cancellables)
    }
    
    func testResultWithCustomTip_For_4Person(){
        let bill:Double = 100
        let tip:Tip = .custom(value: 60)
        let split:Int = 4
        let input = buildInput(bill: bill, tip: tip, split: split)
        let output = sut.tranform(input: input)
        output.updateViewPublisher.sink { result in
            XCTAssertEqual(result.amountPerPerson, 40.0)
            XCTAssertEqual(result.totalBill, 160)
            XCTAssertEqual(result.totalTip, 60)
        }.store(in: &cancellables)
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        cancellables = nil
    }
    

}
