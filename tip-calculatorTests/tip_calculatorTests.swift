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
    private var audioPlayerService:MockAudioPlayerService!
    private var logoViewTapSubject: PassthroughSubject<Void, Never>!
        
    override func setUp() {
        audioPlayerService = .init()
        sut = .init(audioPlayerServer: audioPlayerService)
        logoViewTapSubject = .init()
        cancellables = .init()
        super.setUp()
    }
    
    func buildInput(bill:Double, tip:Tip, split: Int) -> CalculatorVM.Input {
        return .init(billPublisher: Just(bill).eraseToAnyPublisher(),
                     tipPublisher: Just(tip).eraseToAnyPublisher(),
                     splitPublisher: Just(split).eraseToAnyPublisher(),
                     logoViewTapPublisher: logoViewTapSubject.eraseToAnyPublisher())
    }
    
    
    
    func testResultWithoutTipFor_1Person(){
        let bill: Double = 100.0
        let tip: Tip = .none
        let split: Int = 1
        let input = buildInput(bill: bill, tip: tip, split: split)
        sut.bind(input: input)
        sut.$result.sink { result in
            XCTAssertEqual(result.amountPerPerson, 100.0)
            XCTAssertEqual(result.totalBill, 100)
            XCTAssertEqual(result.totalTip, 0)
        }.store(in: &cancellables)
    }

    func testResultWithoutTipFor_2Person(){
        let bill: Double = 100
        let tip: Tip = .none
        let split: Int = 2
        let input = buildInput(bill: bill, tip: tip, split: split)
        sut.bind(input: input)
        sut.$result.sink { result in
            XCTAssertEqual(result.amountPerPerson, 50.0)
            XCTAssertEqual(result.totalBill, 100)
            XCTAssertEqual(result.totalTip, 0)
        }.store(in: &cancellables)
    }

    func testResultWith_10PercentTip_For_2Person(){
        let bill: Double = 100
        let tip: Tip = .tenPercent
        let split: Int = 2
        let input = buildInput(bill: bill, tip: tip, split: split)
        sut.bind(input: input)
        sut.$result.sink { result in
            XCTAssertEqual(result.amountPerPerson, 55.0)
            XCTAssertEqual(result.totalBill, 110)
            XCTAssertEqual(result.totalTip, 10)
        }.store(in: &cancellables)
    }

    func testResultWithCustomTip_For_4Person(){
        let bill: Double = 100
        let tip: Tip = .custom(value: 60)
        let split: Int = 4
        let input = buildInput(bill: bill, tip: tip, split: split)
        sut.bind(input: input)
        sut.$result.sink { result in
            XCTAssertEqual(result.amountPerPerson, 40.0)
            XCTAssertEqual(result.totalBill, 160)
            XCTAssertEqual(result.totalTip, 60)
        }.store(in: &cancellables)
    }

    func testSoundPlay_and_CalculatorResetTap(){
        let input = buildInput(bill: 100, tip: .tenPercent, split: 2)
        sut.bind(input: input)
        let expectation1 = XCTestExpectation(description: "Reset calculator called!")
        let expectation2 = audioPlayerService.expectation
        sut.resetPublisher.sink { _ in
            expectation1.fulfill()
        }.store(in: &cancellables)
        logoViewTapSubject.send()
        wait(for: [expectation1, expectation2], timeout: 1.0)
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        cancellables = nil
        audioPlayerService = nil
        logoViewTapSubject = nil
    }
    

}

class MockAudioPlayerService: AudioPlayerService {
    
    var expectation = XCTestExpectation(description: "PlaySound is called!")
   
    func playSound() {
        expectation.fulfill()
    }
    
    
}
