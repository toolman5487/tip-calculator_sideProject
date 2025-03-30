//
//  CalculatorVM.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/30.
//

import Foundation
import Combine

class CalculatorVM{
    private var cancellables: Set<AnyCancellable> = []
    
    struct Input{
        let billPublisher: AnyPublisher<Double, Never>
        let tipPublisher: AnyPublisher<Tip, Never>
        let splitPublisher: AnyPublisher<Int, Never>
    }
    
    struct Output{
        let updateViewPublisher:AnyPublisher<Result, Never>
    }
    
    func tranform(input:Input)->Output{
        input.tipPublisher.sink { tip in
            print("Tip: \(tip)")
        }.store(in: &cancellables)
        let result = Result(amountPerPerson: 500, totalBill: 1000, totalTip: 50.0)
        return Output(updateViewPublisher: Just(result).eraseToAnyPublisher())
    }
}
