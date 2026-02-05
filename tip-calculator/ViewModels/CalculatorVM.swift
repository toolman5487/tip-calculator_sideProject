//
//  CalculatorVM.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/30.
//

import Foundation
import Combine

@MainActor
final class CalculatorVM {
    
    private var cancellables: Set<AnyCancellable> = []
    private let audioPlayerServer: AudioPlayerService

    @Published private(set) var result: Result = Result(
        amountPerPerson: 0,
        totalBill: 0,
        totalTip: 0,
        bill: 0,
        tip: .none,
        split: 1
    )

    private let resetSubject = PassthroughSubject<Void, Never>()
    var resetPublisher: AnyPublisher<Void, Never> { resetSubject.eraseToAnyPublisher() }

    init(audioPlayerServer: AudioPlayerService = DefaultAudioPlayerService()) {
        self.audioPlayerServer = audioPlayerServer
    }

    struct Input {
        let billPublisher: AnyPublisher<Double, Never>
        let tipPublisher: AnyPublisher<Tip, Never>
        let splitPublisher: AnyPublisher<Int, Never>
        let logoViewTapPublisher: AnyPublisher<Void, Never>
    }
    
    private func getTipAmount(bill:Double, tip:Tip)->Double{
        switch tip{
        case .none:
            return 0
        case .tenPercent:
            return bill * 0.1
        case .fifteenPercent:
            return bill * 0.15
        case .twentyPercent:
            return bill * 0.2
        case .custom(let value):
            return Double(value)
        }
    }
    
    func bind(input: Input) {
        Publishers.CombineLatest3(
            input.billPublisher,
            input.tipPublisher,
            input.splitPublisher
        )
        .map { [weak self] bill, tip, split -> Result in
            guard let self else {
                return Result(
                    amountPerPerson: 0,
                    totalBill: 0,
                    totalTip: 0,
                    bill: 0,
                    tip: .none,
                    split: 1
                )
            }
            let totalTip = self.getTipAmount(bill: bill, tip: tip)
            let totalBill = bill + totalTip
            let amountPerPerson = totalBill / Double(split)
            return Result(
                amountPerPerson: amountPerPerson,
                totalBill: totalBill,
                totalTip: totalTip,
                bill: bill,
                tip: tip,
                split: split
            )
        }
        .assign(to: &$result)

        input.logoViewTapPublisher
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.audioPlayerServer.playSound()
            })
            .sink { [weak self] _ in
                self?.resetSubject.send(())
            }
            .store(in: &cancellables)
    }
}
