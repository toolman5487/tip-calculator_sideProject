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

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = .singleLine
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 44
        table.showsVerticalScrollIndicator = false
        return table
    }()

    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        button.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: config), for: .normal)
        button.tintColor = .systemBackground
        button.backgroundColor = ThemeColor.secondary
        button.addCornerRadius(radius: 8)
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
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
        setupHeaderView()
        bindViewModel()
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
        let config = UIImage.SymbolConfiguration(weight: .bold)

        switch viewModel.mode {
        case .editable:
            let editItem = UIBarButtonItem(
                image: UIImage(systemName: "slider.horizontal.3", withConfiguration: config),
                style: .plain,
                target: self,
                action: #selector(editButtonTapped)
            )
            let deleteItem = UIBarButtonItem(
                image: UIImage(systemName: "trash", withConfiguration: config),
                style: .plain,
                target: self,
                action: #selector(deleteButtonTapped)
            )
            navigationItem.rightBarButtonItems = [editItem, deleteItem]
        case .readOnly:
            navigationItem.rightBarButtonItems = []
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ResultDeetailTableViewCell.self, forCellReuseIdentifier: ResultDeetailTableViewCell.reuseId)
        tableView.register(ResultDetailImageValueCell.self, forCellReuseIdentifier: ResultDetailImageValueCell.reuseId)
        tableView.register(ResultDetailLocationCell.self, forCellReuseIdentifier: ResultDetailLocationCell.locationReuseId)
        view.addSubview(tableView)
        view.addSubview(shareButton)

        shareButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.height.equalTo(52)
        }
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(shareButton.snp.top).offset(-16)
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
        amountLabel.text = viewModel.headerAmountText
        amountLabel.font = UIFont.systemFont(ofSize: 60, weight: .bold, width: .condensed)
        amountLabel.textColor = ThemeColor.primary
        amountLabel.textAlignment = .center
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
        }

        tableView.tableHeaderView = headerView
    }

    // MARK: - Actions

    @objc private func editButtonTapped() {
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

    @objc private func shareButtonTapped() {
        let activityVC = UIActivityViewController(activityItems: [viewModel.shareText], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = shareButton
            popover.sourceRect = shareButton.bounds
        }
        present(activityVC, animated: true)
    }

    @objc private func deleteButtonTapped() {
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
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultDeetailTableViewCell.reuseId, for: indexPath) as! ResultDeetailTableViewCell
            cell.configure(title: title, value: value, systemImageName: icon)
            return cell

        case .category(let title, let imageName):
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultDetailImageValueCell.reuseId, for: indexPath) as! ResultDetailImageValueCell
            cell.configure(title: title, systemImageName: "tag.fill", valueImageName: imageName, valueImageTintColor: ThemeColor.secondary)
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

extension ResultDetailViewController: UITableViewDelegate {}
