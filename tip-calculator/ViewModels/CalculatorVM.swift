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

    @Published private(set) var selectedCategory: Category = .none

    @Published private(set) var result: Result = Result(
        amountPerPerson: 0,
        totalBill: 0,
        totalTip: 0,
        bill: 0,
        tip: .none,
        split: 1,
        categoryIdentifier: nil
    )

    private let resetSubject = PassthroughSubject<Void, Never>()
    var resetPublisher: AnyPublisher<Void, Never> { resetSubject.eraseToAnyPublisher() }

    private let showTotalResultSubject = PassthroughSubject<Result, Never>()
    var showTotalResultPublisher: AnyPublisher<Result, Never> { showTotalResultSubject.eraseToAnyPublisher() }

    private let showCategoryPickerSubject = PassthroughSubject<Category, Never>()
    var showCategoryPickerPublisher: AnyPublisher<Category, Never> { showCategoryPickerSubject.eraseToAnyPublisher() }

    init(audioPlayerServer: AudioPlayerService = DefaultAudioPlayerService()) {
        self.audioPlayerServer = audioPlayerServer
    }

    struct Input {
        let billPublisher: AnyPublisher<Double, Never>
        let tipPublisher: AnyPublisher<Tip, Never>
        let splitPublisher: AnyPublisher<Int, Never>
        let mainGridCategoryTapPublisher: AnyPublisher<Category, Never>
        let sheetCategorySelectPublisher: AnyPublisher<Category, Never>
        let logoViewTapPublisher: AnyPublisher<Void, Never>
        let confirmTapPublisher: AnyPublisher<Void, Never>
        let moreOptionsTapPublisher: AnyPublisher<Void, Never>
        let resultDismissedPublisher: AnyPublisher<Void, Never>
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
        input.mainGridCategoryTapPublisher
            .sink { [weak self] tapped in
                guard let self else { return }
                selectedCategory = selectedCategory == tapped ? .none : tapped
            }
            .store(in: &cancellables)

        input.sheetCategorySelectPublisher
            .sink { [weak self] category in
                self?.selectedCategory = category
            }
            .store(in: &cancellables)

        Publishers.CombineLatest4(
            input.billPublisher,
            input.tipPublisher,
            input.splitPublisher,
            $selectedCategory
        )
        .map { [weak self] bill, tip, split, category -> Result in
            guard let self else {
                return Result(
                    amountPerPerson: 0,
                    totalBill: 0,
                    totalTip: 0,
                    bill: 0,
                    tip: .none,
                    split: 1,
                    categoryIdentifier: nil
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
                split: split,
                categoryIdentifier: category == .none ? nil : category.identifier
            )
        }
        .assign(to: &$result)

        input.logoViewTapPublisher
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.audioPlayerServer.playSound()
            })
            .sink { [weak self] _ in
                self?.selectedCategory = .none
                self?.resetSubject.send(())
            }
            .store(in: &cancellables)

        input.confirmTapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                self.showTotalResultSubject.send(self.result)
            }
            .store(in: &cancellables)

        input.moreOptionsTapPublisher
            .sink { [weak self] _ in
                self?.showCategoryPickerSubject.send(self?.selectedCategory ?? .none)
            }
            .store(in: &cancellables)

        input.resultDismissedPublisher
            .sink { [weak self] _ in
                self?.selectedCategory = .none
                self?.resetSubject.send(())
            }
            .store(in: &cancellables)
    }

    func reset() {
        resetSubject.send(())
    }
}
