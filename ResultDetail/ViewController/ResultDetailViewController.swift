//
//  ResultDetailViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/6.
//

import UIKit
import SnapKit
import MapKit

@MainActor
final class ResultDetailViewController: BaseViewController {

    // MARK: - Properties

    private let viewModel: ResultDetailViewModel

    private enum Section: Int, CaseIterable {
        case time
        case total
        case bill
        case tip
        case split
        case tipSetting
        case category
        case address
    }

    private lazy var sections: [Section] = {
        var all = Section.allCases
        if !viewModel.shouldShowCategorySection {
            all.removeAll { $0 == .category }
        }
        if !viewModel.shouldShowAddressSection {
            all.removeAll { $0 == .address }
        }
        return all
    }()
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = .singleLine
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 44
        table.showsVerticalScrollIndicator = false
        return table
    }()

    // MARK: - Init

    init(item: RecordDisplayItem) {
        self.viewModel = ResultDetailViewModel(item: item)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "消費明細"
        navigationItem.largeTitleDisplayMode = .never

        setupNavigation()
        setupTableViewLayout()
        setupHeaderView()
    }

    // MARK: - Setup

    private func setupNavigation() {
        let config = UIImage.SymbolConfiguration(weight: .bold)
        let shareImage = UIImage(systemName: "square.and.arrow.up", withConfiguration: config)
        let deleteImage = UIImage(systemName: "trash", withConfiguration: config)

        let shareItem = UIBarButtonItem(image: shareImage,
                                        style: .plain,
                                        target: self,
                                        action: #selector(shareButtonTapped))
        let deleteItem = UIBarButtonItem(image: deleteImage,
                                         style: .plain,
                                         target: self,
                                         action: #selector(deleteButtonTapped))

        navigationItem.rightBarButtonItems = [deleteItem, shareItem]
    }

    private func setupTableViewLayout() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ResultDeetailTableViewCell.self, forCellReuseIdentifier: ResultDeetailTableViewCell.reuseId)
        tableView.register(ResultDetailImageValueCell.self, forCellReuseIdentifier: ResultDetailImageValueCell.reuseId)
        tableView.register(ResultDetailLocationCell.self, forCellReuseIdentifier: ResultDetailLocationCell.locationReuseId)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupHeaderView() {
        let headerHeight: CGFloat = 160
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: headerHeight))
        headerView.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.text = "每人應付金額"
        titleLabel.font = ThemeFont.demiBold(Ofsize: 16)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center

        let amountLabel = UILabel()
        amountLabel.text = viewModel.item.amountPerPersonText
        amountLabel.font = UIFont.systemFont(ofSize: 60, weight: .bold, width: .condensed)
        amountLabel.textColor = ThemeColor.primary
        amountLabel.textAlignment = .center

        headerView.addSubview(titleLabel)
        headerView.addSubview(amountLabel)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(36)
        }
        amountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top)
        }

        tableView.tableHeaderView = headerView
    }

    // MARK: - Actions

    @objc private func shareButtonTapped() {
        let text = shareText
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)

        if let popover = activityVC.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }

        present(activityVC, animated: true)
    }

    private var shareText: String {
        let item = viewModel.item
        var lines = [
            "消費明細",
            "每人應付金額：\(item.amountPerPersonText)",
            "時間：\(item.dateText)",
            "總金額：\(item.totalBillText)",
            "帳單金額：\(item.billText)",
            "小費：\(item.totalTipText)",
            "分攤人數：\(item.splitText)",
            "小費設定：\(item.tipDisplayText)"
        ]
        if item.categoryDisplayText != "—" {
            lines.append("消費種類：\(item.categoryDisplayText)")
        }
        if !item.addressText.isEmpty {
            lines.append("消費地點：\(item.addressText)")
        }
        return lines.joined(separator: "\n")
    }

    @objc private func deleteButtonTapped() {
        guard viewModel.item.id != nil else { return }

        let alert = UIAlertController(
            title: "刪除紀錄",
            message: "刪除後無法復原，確定要刪除這筆紀錄嗎？",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "刪除", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.viewModel.deleteRecord()

            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        })

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ResultDetailViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.row]

        switch section {
        case .time:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ResultDeetailTableViewCell.reuseId,
                for: indexPath
            ) as! ResultDeetailTableViewCell
            cell.configure(title: "時間",
                           value: viewModel.item.dateText,
                           systemImageName: "clock")
            return cell
        case .total:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ResultDeetailTableViewCell.reuseId,
                for: indexPath
            ) as! ResultDeetailTableViewCell
            cell.configure(title: "總金額",
                           value: viewModel.item.totalBillText,
                           systemImageName: "dollarsign.circle.fill")
            return cell
        case .bill:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ResultDeetailTableViewCell.reuseId,
                for: indexPath
            ) as! ResultDeetailTableViewCell
            cell.configure(title: "帳單金額",
                           value: viewModel.item.billText,
                           systemImageName: "doc.text.fill")
            return cell
        case .tip:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ResultDeetailTableViewCell.reuseId,
                for: indexPath
            ) as! ResultDeetailTableViewCell
            cell.configure(title: "小費",
                           value: viewModel.item.totalTipText,
                           systemImageName: "percent")
            return cell
        case .split:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ResultDeetailTableViewCell.reuseId,
                for: indexPath
            ) as! ResultDeetailTableViewCell
            cell.configure(title: "分攤人數",
                           value: viewModel.item.splitText,
                           systemImageName: "person.3.fill")
            return cell
        case .tipSetting:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ResultDeetailTableViewCell.reuseId,
                for: indexPath
            ) as! ResultDeetailTableViewCell
            cell.configure(title: "小費設定",
                           value: viewModel.item.tipDisplayText,
                           systemImageName: "slider.horizontal.3")
            return cell
        case .category:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ResultDetailImageValueCell.reuseId,
                for: indexPath
            ) as! ResultDetailImageValueCell
            cell.configure(title: "消費種類", systemImageName: "tag.fill", valueImageName: viewModel.categorySystemImageName, valueImageTintColor: ThemeColor.secondary)
            return cell
        case .address:
            let text = viewModel.item.addressText.isEmpty ? "未紀錄" : viewModel.item.addressText
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ResultDetailLocationCell.locationReuseId,
                for: indexPath
            ) as! ResultDetailLocationCell
            let coord: CLLocationCoordinate2D?
            if let lat = viewModel.item.latitude,
               let lon = viewModel.item.longitude {
                coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            } else {
                coord = nil
            }
            cell.configure(title: "消費地點",
                           value: text,
                           coordinate: coord)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension ResultDetailViewController: UITableViewDelegate {}
