//
//  ViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/27.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit

class CalculatorVC: UIViewController {

    private let logoView = LogoView()
    private let resultView = ResultView()
    private let billInputView = BillInputView()
    private let tipInputView = TipInputView()
    private let splitInputView = SplitInputView()

    private let vm = CalculatorVM()
    private var cancellables = Set<AnyCancellable>()
    private lazy var viewTapPublisher: AnyPublisher<Void,Never> = {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        view.addGestureRecognizer(tapGesture)
        return tapGesture.tapPublisher.flatMap { _ in
            Just(())
        }.eraseToAnyPublisher()
    }()

    private lazy var logoViewTapPublisher: AnyPublisher<Void,Never> = {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.numberOfTapsRequired = 2
        logoView.addGestureRecognizer(tapGesture)
        return tapGesture.tapPublisher.flatMap { _ in
            Just(())
        }.eraseToAnyPublisher()
    }()

    private enum Row: Int, CaseIterable {
        case logo
        case result
        case billInput
        case tipInput
        case splitInput

        var reuseId: String {
            switch self {
            case .logo: return LogoCell.reuseId
            case .result: return ResultCell.reuseId
            case .billInput: return BillInputCell.reuseId
            case .tipInput: return TipInputCell.reuseId
            case .splitInput: return SplitInputCell.reuseId
            }
        }

        /// 與原本 StackView spacing 36 一致（每列下方留白）
        private static let rowSpacing: CGFloat = 36

        var rowHeight: CGFloat {
            switch self {
            case .logo: return 48 + Self.rowSpacing
            case .result: return 224 + Self.rowSpacing
            case .billInput: return 56 + Self.rowSpacing
            case .tipInput: return 56 + 56 + 15 + Self.rowSpacing
            case .splitInput: return 56
            }
        }
    }

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = .none
        table.backgroundColor = ThemeColor.bg
        table.contentInsetAdjustmentBehavior = .never
        table.showsVerticalScrollIndicator = false
        table.register(LogoCell.self, forCellReuseIdentifier: LogoCell.reuseId)
        table.register(ResultCell.self, forCellReuseIdentifier: ResultCell.reuseId)
        table.register(BillInputCell.self, forCellReuseIdentifier: BillInputCell.reuseId)
        table.register(TipInputCell.self, forCellReuseIdentifier: TipInputCell.reuseId)
        table.register(SplitInputCell.self, forCellReuseIdentifier: SplitInputCell.reuseId)
        table.dataSource = self
        table.delegate = self
        return table
    }()

    private func observe(){
        viewTapPublisher.sink { [unowned self] _ in
            view.endEditing(true)
        }.store(in: &cancellables)

        logoViewTapPublisher.sink { _ in
            print("Logo is tapped")
        }.store(in: &cancellables)
    }

    func bind(){
        let input = CalculatorVM.Input(
            billPublisher: billInputView.valuePublisher,
            tipPublisher: tipInputView.valuePublusher,
            splitPublisher: splitInputView.valuePublisher,
            logoViewTapPulisher: logoViewTapPublisher)

        let output = vm.tranform(input: input)
        output.updateViewPublisher.sink { [unowned self] result in
            resultView.configure(result: result)
        }.store(in: &cancellables)

        output.resetCalculatorPublisher.sink { [unowned self] _ in
            print("Reset the form!")
            billInputView.billReset()
            tipInputView.tipReset()
            splitInputView.splitReset()

            UIView.animate(
                withDuration: 0.1,
                delay: 0,
                usingSpringWithDamping: 5.0,
                initialSpringVelocity: 0.5,
                options: .curveEaseInOut){
                    self.logoView.transform = .init(scaleX: 1.5, y: 1.5)
                } completion: { _ in
                    UIView.animate(withDuration: 0.1) {
                        self.logoView.transform = .identity
                    }
                }
        }.store(in: &cancellables)
    }

    private func layout(){
        view.backgroundColor = ThemeColor.bg
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        bind()
        observe()
    }
}

// MARK: - UITableViewDataSource
extension CalculatorVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Row(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        switch row {
        case .logo:
            let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseId, for: indexPath) as! LogoCell
            cell.configure(with: logoView)
            return cell
        case .result:
            let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseId, for: indexPath) as! ResultCell
            cell.configure(with: resultView)
            return cell
        case .billInput:
            let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseId, for: indexPath) as! BillInputCell
            cell.configure(with: billInputView)
            return cell
        case .tipInput:
            let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseId, for: indexPath) as! TipInputCell
            cell.configure(with: tipInputView)
            return cell
        case .splitInput:
            let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseId, for: indexPath) as! SplitInputCell
            cell.configure(with: splitInputView)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension CalculatorVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let row = Row(rawValue: indexPath.row) else { return 0 }
        return row.rowHeight
    }
}
