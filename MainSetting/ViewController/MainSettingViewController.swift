//
//  MainSettingViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/14.
//

import Foundation
import UIKit
import SnapKit

@MainActor
final class MainSettingViewController: BaseViewController {

    // MARK: - View Model

    private let viewModel = MainSettingViewModel()

    // MARK: - UI Components

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .systemGroupedBackground
        tv.dataSource = self
        tv.delegate = self
        tv.register(SettingRowCell.self, forCellReuseIdentifier: SettingRowCell.reuseId)
        tv.register(SettingToggleCell.self, forCellReuseIdentifier: SettingToggleCell.reuseId)
        return tv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        viewModel.load()
        tableView.reloadData()
    }

    // MARK: - Setup

    override func setupUI() {
        super.setupUI()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupNavigation() {
        title = "設定"
    }

    // MARK: - Actions

    private func handleSelect(item: SettingItem) {
        switch viewModel.action(for: item.id) {
        case .none:
            break
        case .openSystemSettings:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension MainSettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section >= 0, section < viewModel.sections.count else { return 0 }
        return viewModel.sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = viewModel.item(at: indexPath) else {
            return tableView.dequeueReusableCell(withIdentifier: SettingRowCell.reuseId, for: indexPath)
        }
        if case .toggle(let isOn) = item.accessory {
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingToggleCell.reuseId, for: indexPath) as! SettingToggleCell
            cell.configure(title: item.title, isOn: isOn) { [weak self] newValue in
                self?.viewModel.setHapticEnabled(newValue)
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingRowCell.reuseId, for: indexPath) as! SettingRowCell
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.detail
        cell.detailTextLabel?.isHidden = (item.detail == nil || item.detail?.isEmpty == true)
        cell.accessoryType = (item.accessory == .disclosure) ? .disclosureIndicator : .none
        cell.selectionStyle = .default
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MainSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let item = viewModel.item(at: indexPath) else { return }
        if case .toggle = item.accessory { return }
        handleSelect(item: item)
    }
}
