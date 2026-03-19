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
        tv.register(HapticFeedbackSettingCell.self, forCellReuseIdentifier: HapticFeedbackSettingCell.cellReuseId)
        tv.register(AboutAppSettingCell.self, forCellReuseIdentifier: AboutAppSettingCell.cellReuseId)
        tv.register(OpenSystemSettingsCell.self, forCellReuseIdentifier: OpenSystemSettingsCell.cellReuseId)
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

    private func setupNavigation() {title = "設定"}

    // MARK: - Actions

    private func handleSelect(item: SettingItem) {
        switch viewModel.action(for: item.id) {
        case .none:
            break
        case .showAbout:
            let vc = AppIndicatorViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .openSystemSettings:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension MainSettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return max(0, viewModel.items.count - 1)
        default: return 0
        }
    }

    private func flatIndex(for indexPath: IndexPath) -> Int {
        switch indexPath.section {
        case 0: return 0
        case 1: return indexPath.row + 1
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let flatIndex = flatIndex(for: indexPath)
        guard let item = viewModel.item(at: flatIndex) else {
            return tableView.dequeueReusableCell(withIdentifier: SettingRowCell.reuseId, for: indexPath)
        }
        switch item.id {
        case .hapticFeedback:
            let cell = tableView.dequeueReusableCell(withIdentifier: HapticFeedbackSettingCell.cellReuseId, for: indexPath) as! HapticFeedbackSettingCell
            cell.configure(isOn: SettingKeys.isHapticEnabled) { [weak self] newValue in
                self?.viewModel.setHapticEnabled(newValue)
            }
            return cell
        case .about:
            let cell = tableView.dequeueReusableCell(withIdentifier: AboutAppSettingCell.cellReuseId, for: indexPath) as! AboutAppSettingCell
            cell.configure()
            return cell
        case .openSystemSettings:
            let cell = tableView.dequeueReusableCell(withIdentifier: OpenSystemSettingsCell.cellReuseId, for: indexPath) as! OpenSystemSettingsCell
            cell.configure()
            return cell
        case .version:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingRowCell.reuseId, for: indexPath) as! SettingRowCell
            cell.configure(title: item.title, detail: item.detail)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension MainSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let flatIndex = flatIndex(for: indexPath)
        guard let item = viewModel.item(at: flatIndex) else { return }
        if item.id == .hapticFeedback { return }
        handleSelect(item: item)
    }
}
