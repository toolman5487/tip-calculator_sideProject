//
//  ResultDetailViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/6.
//

import UIKit
import Combine
import MapKit
import SnapKit

@MainActor
final class ResultDetailViewController: BaseViewController {

    // MARK: - Properties

    private let viewModel: ResultDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    private var headerAmountLabel: UILabel?
    private var didSetupTableExtras = false

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = .singleLine
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 44
        table.showsVerticalScrollIndicator = false
        return table
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        button.setImage(UIImage(systemName: "trash", withConfiguration: config), for: .normal)
        button.tintColor = .systemBackground
        button.backgroundColor = ThemeColor.trendUp
        button.addCornerRadius(radius: 8)
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Init

    init(item: RecordDisplayItem, mode: ResultDetailMode = .editable) {
        self.viewModel = ResultDetailViewModel(item: item, mode: mode)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "消費明細"
        navigationItem.largeTitleDisplayMode = .never

        setupNavigation()
        setupTableView()
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !didSetupTableExtras, tableView.bounds.width > 0 else { return }
        didSetupTableExtras = true
        setupHeaderView()
        setupFooterView()
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.$item
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                guard let self else { return }
                headerAmountLabel?.text = item.amountPerPersonText
                tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    // MARK: - Setup

    private func setupNavigation() {
        switch viewModel.mode {
        case .editable:
            navigationItem.rightBarButtonItems = [
                .editButton { [weak self] in self?.editButtonTapped() },
                .shareButton { [weak self] in self?.shareButtonTapped() }
            ]
        case .readOnly:
            navigationItem.rightBarButtonItems = [
                .shareButton { [weak self] in self?.shareButtonTapped() }
            ]
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ResultDetailTableViewCell.self, forCellReuseIdentifier: ResultDetailTableViewCell.reuseId)
        tableView.register(ResultDetailImageValueCell.self, forCellReuseIdentifier: ResultDetailImageValueCell.reuseId)
        tableView.register(ResultDetailLocationCell.self, forCellReuseIdentifier: ResultDetailLocationCell.locationReuseId)

        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupHeaderView() {
        let headerHeight: CGFloat = 160
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight))
        headerView.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.text = "每人應付金額"
        titleLabel.font = ThemeFont.demiBold(Ofsize: 16)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center

        let amountLabel = UILabel()
        amountLabel.text = viewModel.headerAmountText
        amountLabel.font = UIFont.systemFont(ofSize: 60, weight: .bold, width: .condensed)
        amountLabel.textColor = ThemeColor.primary
        amountLabel.textAlignment = .center
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.minimumScaleFactor = 0.4
        amountLabel.numberOfLines = 1
        headerAmountLabel = amountLabel

        headerView.addSubview(titleLabel)
        headerView.addSubview(amountLabel)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(36)
        }
        amountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top)
            make.left.right.equalToSuperview().inset(16)
        }

        tableView.tableHeaderView = headerView
    }

    private func setupFooterView() {
        guard viewModel.mode == .editable, viewModel.canDelete else {
            tableView.tableFooterView = nil
            return
        }
        let footerHeight: CGFloat = 88
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: footerHeight))
        footerView.backgroundColor = .clear

        footerView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(52)
        }

        tableView.tableFooterView = footerView
    }

    // MARK: - Actions

    private func editButtonTapped() {
        guard let id = viewModel.item.id else { return }
        let editVC = ResultDetailEditViewController(recordId: id)
        let nav = UINavigationController(rootViewController: editVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .large
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }

    private func shareButtonTapped() {
        let activityVC = UIActivityViewController(activityItems: [viewModel.shareText], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController,
           let shareItem = navigationItem.rightBarButtonItems?.last {
            popover.barButtonItem = shareItem
        }
        present(activityVC, animated: true)
    }

    @objc private func deleteButtonTapped() {
        Haptic.barButtonImpact()
        guard viewModel.canDelete else { return }
        let alert = UIAlertController(title: "刪除紀錄", message: "刪除後無法復原，確定要刪除這筆紀錄嗎？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "刪除", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteRecord()
            guard let self else { return }
            if self.navigationController?.presentingViewController != nil {
                self.navigationController?.dismiss(animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ResultDetailViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = viewModel.rows[indexPath.row]

        switch row {
        case .value(let title, let value, let icon):
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultDetailTableViewCell.reuseId, for: indexPath) as! ResultDetailTableViewCell
            cell.configure(title: title, value: value, systemImageName: icon)
            return cell

        case .category(let title, let imageName):
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultDetailImageValueCell.reuseId, for: indexPath) as! ResultDetailImageValueCell
            cell.configure(title: title, systemImageName: "tag.fill", valueImageName: imageName, valueImageTintColor: ThemeColor.selected)
            return cell

        case .location(let title, let value, let lat, let lon):
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultDetailLocationCell.locationReuseId, for: indexPath) as! ResultDetailLocationCell
            let coord: CLLocationCoordinate2D? = (lat != nil && lon != nil) ? CLLocationCoordinate2D(latitude: lat!, longitude: lon!) : nil
            cell.configure(title: title, value: value, coordinate: coord)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension ResultDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = viewModel.rows[indexPath.row]
        switch row {
        case .value:
            break
        case .category:
            break
        case .location(_, let value, let lat, let lon):
            guard let lat, let lon else { return }
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = value
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        }
    }
}
