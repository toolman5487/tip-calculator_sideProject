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
        
    override class func setUp() {
        sut = .init()
        cancellables = .init()
        super.setUp()
    }
    
    override class func tearDown() {
        super.tearDown()
        sut = nil
    }
    

}
