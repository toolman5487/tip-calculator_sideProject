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

@MainActor
final class CalculatorVC: BaseViewController {

    private let vm = CalculatorVM()
    private var cancellables = Set<AnyCancellable>()
    private var hasBoundCells = false
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

    @MainActor
    private enum Row: Int, CaseIterable {
        case result
        case billInput
        case tipInput
        case splitInput
        case confirmButton

        var reuseId: String {
            switch self {
            case .result: return ResultCell.reuseId
            case .billInput: return BillInputCell.reuseId
            case .tipInput: return TipInputCell.reuseId
            case .splitInput: return SplitInputCell.reuseId
            case .confirmButton: return ConfirmButtonCell.reuseId
            }
        }

        private static let rowSpacing: CGFloat = 36

        var rowHeight: CGFloat {
            switch self {
            case .result: return 260
            case .billInput: return 92
            case .tipInput: return 151
            case .splitInput: return 92
            case .confirmButton: return 68
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
        table.register(ConfirmButtonCell.self, forCellReuseIdentifier: ConfirmButtonCell.reuseId)
        table.dataSource = self
        table.delegate = self
        return table
    }()

    func bindingVM() {
        viewTapPublisher.sink { [weak self] _ in
            self?.view.endEditing(true)
        }.store(in: &cancellables)
    }

    private func bindCellsIfNeeded() {
        guard !hasBoundCells else { return }
        hasBoundCells = true

        tableView.reloadData()
        guard let resultCell = tableView.cellForRow(at: IndexPath(row: Row.result.rawValue, section: 0)) as? ResultCell,
              let billInputCell = tableView.cellForRow(at: IndexPath(row: Row.billInput.rawValue, section: 0)) as? BillInputCell,
              let tipInputCell = tableView.cellForRow(at: IndexPath(row: Row.tipInput.rawValue, section: 0)) as? TipInputCell,
              let splitInputCell = tableView.cellForRow(at: IndexPath(row: Row.splitInput.rawValue, section: 0)) as? SplitInputCell,
              let confirmCell = tableView.cellForRow(at: IndexPath(row: Row.confirmButton.rawValue, section: 0)) as? ConfirmButtonCell
        else { return }

        confirmCell.confirmButton.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                let totalVC = TotalResultViewController(result: self.vm.result)

                totalVC.dismissedPublisher
                    .prefix(1)
                    .sink { [weak self] in
                        self?.vm.reset()
                    }
                    .store(in: &self.cancellables)

                let nav = UINavigationController(rootViewController: totalVC)
                nav.modalPresentationStyle = .pageSheet
                nav.modalTransitionStyle = .coverVertical
                if let sheet = nav.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.selectedDetentIdentifier = .medium
                    sheet.prefersGrabberVisible = true
                }
                self.present(nav, animated: true)
            }
            .store(in: &cancellables)

        let input = CalculatorVM.Input(
            billPublisher: billInputCell.billInputView.valuePublisher,
            tipPublisher: tipInputCell.tipInputView.valuePublisher,
            splitPublisher: splitInputCell.splitInputView.valuePublisher,
            logoViewTapPublisher: refreshButtonTapPublisher)
        vm.bind(input: input)

        vm.$result.sink { result in
            resultCell.resultView.configure(result: result)
        }.store(in: &cancellables)

        vm.resetPublisher.sink { [weak self] _ in
            guard let self else { return }
            (self.tableView.cellForRow(at: IndexPath(row: Row.billInput.rawValue, section: 0)) as? BillInputCell)?.billInputView.billReset()
            (self.tableView.cellForRow(at: IndexPath(row: Row.tipInput.rawValue, section: 0)) as? TipInputCell)?.tipInputView.tipReset()
            (self.tableView.cellForRow(at: IndexPath(row: Row.splitInput.rawValue, section: 0)) as? SplitInputCell)?.splitInputView.splitReset()
        }.store(in: &cancellables)
    }

    private func layout() {
        title = "消費計算機"
        navigationItem.backButtonDisplayMode = .minimal
        view.backgroundColor = ThemeColor.bg
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        view.layoutIfNeeded()
        bindingVM()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bindCellsIfNeeded()
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
        case .confirmButton:
            let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseId, for: indexPath) as! ConfirmButtonCell
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
