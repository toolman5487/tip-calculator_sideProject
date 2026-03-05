//
//  ResultDetailEditViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/4.
//

import UIKit
import SnapKit
import Combine

@MainActor
final class ResultDetailEditViewController: BaseViewController {

    init(recordId: UUID) {
        self.viewModel = ResultDetailEditViewModel(recordId: recordId)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let viewModel: ResultDetailEditViewModel
    private var cancellables = Set<AnyCancellable>()

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 56
        return table
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setupTableView()
        setupLayout()
        setupBinding()
    }

    private func setNavigationBar() {
        title = "編輯消費紀錄"
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ResultDetailEditDatePickerCell.self, forCellReuseIdentifier: ResultDetailEditDatePickerCell.reuseId)
        tableView.register(ResultDetailEditAmountCell.self, forCellReuseIdentifier: ResultDetailEditAmountCell.reuseId)
        tableView.register(ResultDetailEditTipCell.self, forCellReuseIdentifier: ResultDetailEditTipCell.reuseId)
        tableView.register(ResultDetailEditSplitCell.self, forCellReuseIdentifier: ResultDetailEditSplitCell.reuseId)
        tableView.register(ResultDetailEditCategoryCell.self, forCellReuseIdentifier: ResultDetailEditCategoryCell.reuseId)
        tableView.register(ResultDetailEditAddressCell.self, forCellReuseIdentifier: ResultDetailEditAddressCell.reuseId)
        setupTableFooterView()
    }

    private func setupTableFooterView() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 84))
        footerView.backgroundColor = .clear

        let saveButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(weight: .bold)
        saveButton.setImage(UIImage(systemName: "square.and.arrow.down", withConfiguration: config), for: .normal)
        saveButton.tintColor = .systemBackground
        saveButton.backgroundColor = ThemeColor.secondary
        saveButton.addCornerRadius(radius: 8)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)

        footerView.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview()
            make.height.equalTo(52)
        }

        tableView.tableFooterView = footerView
    }

    private func setupLayout() {
        view.addSubview(containerView)
        containerView.addSubview(tableView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupBinding() {
        viewModel.$rows
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    @objc private func saveButtonTapped() {
        guard viewModel.save() else { return }
        view.showToast(message: "編輯成功", position: .bottom(offset: 16), displayDuration: 1) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    private func showTipPicker() {
        let alert = UIAlertController(title: "選擇小費", message: nil, preferredStyle: .actionSheet)
        let options: [(String, Tip)] = [
            ("無", .none),
            ("10%", .tenPercent),
            ("15%", .fifteenPercent),
            ("20%", .twentyPercent)
        ]
        for (title, tip) in options {
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.viewModel.updateTip(tip)
            })
        }
        alert.addAction(UIAlertAction(title: "自訂金額", style: .default) { [weak self] _ in
            self?.showCustomTipAlert()
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        present(alert, animated: true)
    }

    private func showCustomTipAlert() {
        let alert = UIAlertController(title: "輸入自訂小費", message: "請輸入小費金額", preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "金額"
            field.keyboardType = .decimalPad
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "確認", style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text,
                  let value = Int(text), value >= 0 else { return }
            self?.viewModel.updateTip(.custom(value: value))
        })
        present(alert, animated: true)
    }

    private func showCategoryPicker() {
        let category = viewModel.categoryIdentifier.flatMap { Category(identifier: $0) } ?? .none
        let vm = CategoryPickerSheetViewModel(currentCategory: category)
        let vc = CategoryPickerSheetViewController(viewModel: vm)
        vc.onSelect = { [weak self] cat in
            self?.viewModel.updateCategory(cat == .none ? nil : cat.identifier)
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    private func showLocationPicker() {
        let vc = MapLocationPickerViewController(
            initialAddress: viewModel.address.isEmpty ? nil : viewModel.address,
            latitude: viewModel.latitude,
            longitude: viewModel.longitude
        )
        vc.onSelect = { [weak self] address, lat, lon in
            self?.viewModel.updateLocation(address: address, latitude: lat, longitude: lon)
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }
}

extension ResultDetailEditViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = viewModel.rows[indexPath.row]
        switch row {
        case .consumptionTimePicker(let date):
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultDetailEditDatePickerCell.reuseId, for: indexPath) as! ResultDetailEditDatePickerCell
            cell.configure(date: date)
            cell.onDateChanged = { [weak self] d in self?.viewModel.updateConsumptionTime(d) }
            return cell

        case .amount(let value):
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultDetailEditAmountCell.reuseId, for: indexPath) as! ResultDetailEditAmountCell
            cell.configure(value: value)
            cell.onValueChanged = { [weak self] v in self?.viewModel.updateBill(v) }
            return cell

        case .tip(let tip):
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultDetailEditTipCell.reuseId, for: indexPath) as! ResultDetailEditTipCell
            cell.configure(tip: tip)
            cell.onTap = { [weak self] in self?.showTipPicker() }
            return cell

        case .split(let value):
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultDetailEditSplitCell.reuseId, for: indexPath) as! ResultDetailEditSplitCell
            cell.configure(value: value)
            cell.onValueChanged = { [weak self] v in self?.viewModel.updateSplit(v) }
            return cell

        case .category(let identifier):
            let cat = identifier.flatMap { Category(identifier: $0) } ?? .none
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultDetailEditCategoryCell.reuseId, for: indexPath) as! ResultDetailEditCategoryCell
            cell.configure(categoryDisplayName: cat.displayName, systemImageName: cat.systemImageName)
            cell.onTap = { [weak self] in self?.showCategoryPicker() }
            return cell

        case .address(let value):
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultDetailEditAddressCell.reuseId, for: indexPath) as! ResultDetailEditAddressCell
            cell.configure(value: value)
            cell.onTap = { [weak self] in self?.showLocationPicker() }
            return cell
        }
    }
}
