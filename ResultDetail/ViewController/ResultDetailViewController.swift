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

    private let resultDetailItem: RecordDisplayItem

    private enum Section: Int, CaseIterable {
        case time
        case total
        case bill
        case tip
        case split
        case tipSetting
        case address
    }

    private lazy var sections: [Section] = {
        var all = Section.allCases
        if resultDetailItem.addressText.isEmpty,
           resultDetailItem.latitude == nil,
           resultDetailItem.longitude == nil {
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
        self.resultDetailItem = item
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

        setupNavigation()
        setupTableViewLayout()
        setupHeaderView()
    }

    // MARK: - Setup

    private func setupNavigation() {
        let config = UIImage.SymbolConfiguration(weight: .bold)
        let image = UIImage(systemName: "square.and.arrow.up", withConfiguration: config)
        let shareItem = UIBarButtonItem(image: image,
                                        style: .plain,
                                        target: self,
                                        action: #selector(shareButtonTapped))
        navigationItem.rightBarButtonItem = shareItem
    }

    private func setupTableViewLayout() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ResultDeetailTableViewCell.self, forCellReuseIdentifier: ResultDeetailTableViewCell.reuseId)
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
        amountLabel.text = resultDetailItem.amountPerPersonText
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
        let image = snapshot(of: view)

        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)

        if let popover = activityVC.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }

        present(activityVC, animated: true)
    }

    private func snapshot(of targetView: UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: targetView.bounds)
        return renderer.image { _ in
            targetView.drawHierarchy(in: targetView.bounds, afterScreenUpdates: true)
        }
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
                           value: resultDetailItem.dateText,
                           systemImageName: "clock")
            return cell
        case .total:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ResultDeetailTableViewCell.reuseId,
                for: indexPath
            ) as! ResultDeetailTableViewCell
            cell.configure(title: "總金額",
                           value: resultDetailItem.totalBillText,
                           systemImageName: "dollarsign.circle.fill")
            return cell
        case .bill:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ResultDeetailTableViewCell.reuseId,
                for: indexPath
            ) as! ResultDeetailTableViewCell
            cell.configure(title: "帳單金額",
                           value: resultDetailItem.billText,
                           systemImageName: "doc.text.fill")
            return cell
        case .tip:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ResultDeetailTableViewCell.reuseId,
                for: indexPath
            ) as! ResultDeetailTableViewCell
            cell.configure(title: "小費",
                           value: resultDetailItem.totalTipText,
                           systemImageName: "percent")
            return cell
        case .split:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ResultDeetailTableViewCell.reuseId,
                for: indexPath
            ) as! ResultDeetailTableViewCell
            cell.configure(title: "分攤人數",
                           value: resultDetailItem.splitText,
                           systemImageName: "person.3.fill")
            return cell
        case .tipSetting:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ResultDeetailTableViewCell.reuseId,
                for: indexPath
            ) as! ResultDeetailTableViewCell
            cell.configure(title: "小費設定",
                           value: resultDetailItem.tipDisplayText,
                           systemImageName: "slider.horizontal.3")
            return cell
        case .address:
            let text = resultDetailItem.addressText.isEmpty ? "未紀錄" : resultDetailItem.addressText
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ResultDetailLocationCell.locationReuseId,
                for: indexPath
            ) as! ResultDetailLocationCell
            let coord: CLLocationCoordinate2D?
            if let lat = resultDetailItem.latitude,
               let lon = resultDetailItem.longitude {
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
