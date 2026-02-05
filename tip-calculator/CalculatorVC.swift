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

    private let vm = CalculatorVM()
    private var cancellables = Set<AnyCancellable>()
    private lazy var viewTapPublisher: AnyPublisher<Void, Never> = {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        view.addGestureRecognizer(tapGesture)
        return tapGesture.tapPublisher.flatMap { _ in Just(()) }.eraseToAnyPublisher()
    }()
    private lazy var refreshButtonTapPublisher: AnyPublisher<Void, Never> = {
        let config = UIImage.SymbolConfiguration(weight: .bold)
        let image = UIImage(systemName: "arrow.clockwise", withConfiguration: config)
        let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        item.accessibilityIdentifier = "refreshButton"
        navigationItem.rightBarButtonItem = item
        return item.tapPublisher.map { _ in () }.eraseToAnyPublisher()
    }()

    private enum Row: Int, CaseIterable {
        case result
        case billInput
        case tipInput
        case splitInput

        var reuseId: String {
            switch self {
            case .result: return ResultCell.reuseId
            case .billInput: return BillInputCell.reuseId
            case .tipInput: return TipInputCell.reuseId
            case .splitInput: return SplitInputCell.reuseId
            }
        }

        private static let rowSpacing: CGFloat = 36

        var rowHeight: CGFloat {
            switch self {
            case .result: return 224 + Self.rowSpacing
            case .billInput: return 56 + Self.rowSpacing
            case .tipInput: return 56 + 44 + 15 + Self.rowSpacing  // 上排 56 + customButton 44 + 間距 15
            case .splitInput: return 56
            }
        }
    }

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = .none
        table.backgroundColor = ThemeColor.bg
        table.contentInsetAdjustmentBehavior = .automatic
        table.showsVerticalScrollIndicator = false
        table.register(ResultCell.self, forCellReuseIdentifier: ResultCell.reuseId)
        table.register(BillInputCell.self, forCellReuseIdentifier: BillInputCell.reuseId)
        table.register(TipInputCell.self, forCellReuseIdentifier: TipInputCell.reuseId)
        table.register(SplitInputCell.self, forCellReuseIdentifier: SplitInputCell.reuseId)
        table.dataSource = self
        table.delegate = self
        return table
    }()

    func bind() {
        viewTapPublisher.sink { [unowned self] _ in
            view.endEditing(true)
        }.store(in: &cancellables)

        tableView.reloadData()
        tableView.layoutIfNeeded()
        guard let resultCell = tableView.cellForRow(at: IndexPath(row: Row.result.rawValue, section: 0)) as? ResultCell,
              let billInputCell = tableView.cellForRow(at: IndexPath(row: Row.billInput.rawValue, section: 0)) as? BillInputCell,
              let tipInputCell = tableView.cellForRow(at: IndexPath(row: Row.tipInput.rawValue, section: 0)) as? TipInputCell,
              let splitInputCell = tableView.cellForRow(at: IndexPath(row: Row.splitInput.rawValue, section: 0)) as? SplitInputCell
        else { return }

        let input = CalculatorVM.Input(
            billPublisher: billInputCell.billInputView.valuePublisher,
            tipPublisher: tipInputCell.tipInputView.valuePublusher,
            splitPublisher: splitInputCell.splitInputView.valuePublisher,
            logoViewTapPulisher: refreshButtonTapPublisher)

        let output = vm.tranform(input: input)
        output.updateViewPublisher.sink { result in
            resultCell.resultView.configure(result: result)
        }.store(in: &cancellables)

        output.resetCalculatorPublisher.sink { [unowned self] _ in
            (tableView.cellForRow(at: IndexPath(row: Row.billInput.rawValue, section: 0)) as? BillInputCell)?.billInputView.billReset()
            (tableView.cellForRow(at: IndexPath(row: Row.tipInput.rawValue, section: 0)) as? TipInputCell)?.tipInputView.tipReset()
            (tableView.cellForRow(at: IndexPath(row: Row.splitInput.rawValue, section: 0)) as? SplitInputCell)?.splitInputView.splitReset()
        }.store(in: &cancellables)
    }

    private func layout(){
        title = "Calculator"
        view.backgroundColor = ThemeColor.bg
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        view.layoutIfNeeded()
        bind()
    }
}

// MARK: - UITableViewDataSource
extension CalculatorVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Row(rawValue: indexPath.row) else { return UITableViewCell() }
        switch row {
        case .result:
            let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseId, for: indexPath) as! ResultCell
            cell.configure()
            return cell
        case .billInput:
            let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseId, for: indexPath) as! BillInputCell
            cell.configure()
            return cell
        case .tipInput:
            let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseId, for: indexPath) as! TipInputCell
            cell.configure()
            return cell
        case .splitInput:
            let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseId, for: indexPath) as! SplitInputCell
            cell.configure()
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
