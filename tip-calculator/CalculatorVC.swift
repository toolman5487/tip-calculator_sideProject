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
    private let logoViewTapSubject = PassthroughSubject<Void, Never>()

    private let cells = CalculatorCells()

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
        navigationItem.rightBarButtonItem = .refreshBarButton(
            onTap: { [weak self] in self?.logoViewTapSubject.send(()) },
            accessibilityIdentifier: "refreshButton"
        )
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

        cells.confirmButton.onTap = { confirmTapSubject.send(()) }
        cells.categoriesInput.onMoreOptionsTap = { moreOptionsTapSubject.send(()) }

        let input = CalculatorVM.Input(
            billPublisher: cells.billInput.billInputView.valuePublisher,
            tipPublisher: cells.tipInput.tipInputView.valuePublisher,
            splitPublisher: cells.splitInput.splitInputView.valuePublisher,
            mainGridCategoryTapPublisher: cells.categoriesInput.mainGridCategoryTapPublisher,
            sheetCategorySelectPublisher: sheetCategorySelectSubject.eraseToAnyPublisher(),
            logoViewTapPublisher: logoViewTapSubject.eraseToAnyPublisher(),
            confirmTapPublisher: confirmTapSubject.eraseToAnyPublisher(),
            moreOptionsTapPublisher: moreOptionsTapSubject.eraseToAnyPublisher(),
            resultDismissedPublisher: resultDismissedSubject.eraseToAnyPublisher()
        )
        vm.bind(input: input)

        vm.$result
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.cells.result.resultView.configure(result: result)
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
                self?.cells.categoriesInput.categoryInputView.updateSelection(category)
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
        cells.resettables.forEach { $0.reset() }
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
            sheet.selectedDetentIdentifier = .large
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
        case .result:       return cells.result
        case .billInput:    return cells.billInput
        case .categoriesInput: return cells.categoriesInput
        case .tipInput:     return cells.tipInput
        case .splitInput:   return cells.splitInput
        case .confirmButton: return cells.confirmButton
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
