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

    // MARK: - Properties

    private let vm = CalculatorVM()
    private var cancellables = Set<AnyCancellable>()

    private lazy var refreshBarItem: UIBarButtonItem = {
        let config = UIImage.SymbolConfiguration(weight: .bold)
        let image = UIImage(systemName: "arrow.clockwise", withConfiguration: config)
        let item = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        item.accessibilityIdentifier = "refreshButton"
        return item
    }()

    private let resultCell = ResultCell()
    private let billInputCell = BillInputCell()
    private let categoriesInputCell = CategoriesInputCell()
    private let tipInputCell = TipInputCell()
    private let splitInputCell = SplitInputCell()
    private let confirmButtonCell = ConfirmButtonCell()

    private enum Row: Int, CaseIterable {
        case result
        case billInput
        case categoriesInput
        case tipInput
        case splitInput
        case confirmButton
    }

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle = .none
        tv.backgroundColor = ThemeColor.bg
        tv.showsVerticalScrollIndicator = false
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupLayout()
        bind()
    }

    // MARK: - Setup

    private func setupNavigation() {
        title = "消費計算機"
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.rightBarButtonItem = refreshBarItem
    }

    private func setupLayout() {
        view.backgroundColor = ThemeColor.bg
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - Binding

    private func bind() {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.tapPublisher
            .sink { [weak self] _ in self?.view.endEditing(true) }
            .store(in: &cancellables)
        view.addGestureRecognizer(tapGesture)

        let confirmTapSubject = PassthroughSubject<Void, Never>()
        let moreOptionsTapSubject = PassthroughSubject<Void, Never>()
        let resultDismissedSubject = PassthroughSubject<Void, Never>()
        let sheetCategorySelectSubject = PassthroughSubject<Category, Never>()

        confirmButtonCell.onTap = { confirmTapSubject.send(()) }
        categoriesInputCell.onMoreOptionsTap = { moreOptionsTapSubject.send(()) }

        let input = CalculatorVM.Input(
            billPublisher: billInputCell.billInputView.valuePublisher,
            tipPublisher: tipInputCell.tipInputView.valuePublisher,
            splitPublisher: splitInputCell.splitInputView.valuePublisher,
            mainGridCategoryTapPublisher: categoriesInputCell.mainGridCategoryTapPublisher,
            sheetCategorySelectPublisher: sheetCategorySelectSubject.eraseToAnyPublisher(),
            logoViewTapPublisher: refreshBarItem.tapPublisher
                .map { _ in () }
                .eraseToAnyPublisher(),
            confirmTapPublisher: confirmTapSubject.eraseToAnyPublisher(),
            moreOptionsTapPublisher: moreOptionsTapSubject.eraseToAnyPublisher(),
            resultDismissedPublisher: resultDismissedSubject.eraseToAnyPublisher()
        )
        vm.bind(input: input)

        vm.$result
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.resultCell.resultView.configure(result: result)
            }
            .store(in: &cancellables)

        vm.resetPublisher
            .sink { [weak self] _ in self?.resetInputCells() }
            .store(in: &cancellables)

        vm.showTotalResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.presentTotalResult(result: result, onDismiss: { resultDismissedSubject.send(()) })
            }
            .store(in: &cancellables)

        vm.$selectedCategory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] category in
                self?.categoriesInputCell.categoryInputView.updateSelection(category)
            }
            .store(in: &cancellables)

        vm.showCategoryPickerPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentCategory in
                self?.presentCategoryOptionsSheet(currentCategory: currentCategory, onSelect: { sheetCategorySelectSubject.send($0) })
            }
            .store(in: &cancellables)
    }

    private func presentCategoryOptionsSheet(currentCategory: Category, onSelect: @escaping (Category) -> Void) {
        let viewModel = CategoryPickerSheetViewModel(currentCategory: currentCategory)
        let pickerVC = CategoryPickerSheetViewController(viewModel: viewModel)
        pickerVC.onSelect = onSelect
        let nav = UINavigationController(rootViewController: pickerVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }

    // MARK: - Actions

    private func resetInputCells() {
        [billInputCell, categoriesInputCell, tipInputCell, splitInputCell]
            .compactMap { $0 as? Resettable }
            .forEach { $0.reset() }
    }

    private func presentTotalResult(result: Result, onDismiss: @escaping () -> Void) {
        let totalVC = TotalResultViewController(result: result)
        totalVC.dismissedPublisher
            .prefix(1)
            .sink { _ in onDismiss() }
            .store(in: &cancellables)

        let nav = UINavigationController(rootViewController: totalVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
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
        case .result:       return resultCell
        case .billInput:    return billInputCell
        case .categoriesInput: return categoriesInputCell
        case .tipInput:     return tipInputCell
        case .splitInput:   return splitInputCell
        case .confirmButton: return confirmButtonCell
        }
    }
}

// MARK: - UITableViewDelegate

extension CalculatorVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch Row(rawValue: indexPath.row) {
        case .result: return 260
        case .billInput: return 92
        case .categoriesInput: return 152
        case .tipInput: return 152
        case .splitInput: return 92
        case .confirmButton: return 68
        case .none: return 0
        }
    }
}
