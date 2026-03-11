//
//  TotalResultViewController.swift
//  tip-calculator
//

import Combine
import CoreLocation
import Foundation
import SnapKit
import UIKit

@MainActor
final class TotalResultViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: TotalResultViewModel
    private let locationProvider: LocationProviding

    // MARK: - State

    private let dismissedSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public API

    var dismissedPublisher: AnyPublisher<Void, Never> {
        dismissedSubject.eraseToAnyPublisher()
    }

    var onDismiss: (() -> Void)?

    // MARK: - UI Components

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        collection.register(AmountPerPersonCell.self, forCellWithReuseIdentifier: AmountPerPersonCell.reuseId)
        collection.register(TotalBillCell.self, forCellWithReuseIdentifier: TotalBillCell.reuseId)
        collection.register(TotalTipCell.self, forCellWithReuseIdentifier: TotalTipCell.reuseId)
        collection.register(BillCell.self, forCellWithReuseIdentifier: BillCell.reuseId)
        collection.register(TipCell.self, forCellWithReuseIdentifier: TipCell.reuseId)
        collection.register(SplitCell.self, forCellWithReuseIdentifier: SplitCell.reuseId)
        collection.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseId)
        collection.register(LocationCell.self, forCellWithReuseIdentifier: LocationCell.reuseId)
        collection.register(SaveRecordCell.self, forCellWithReuseIdentifier: SaveRecordCell.reuseId)
        return collection
    }()

    // MARK: - Init

    init(result: Result, locationProvider: LocationProviding = LocationService.shared) {
        self.locationProvider = locationProvider
        self.viewModel = TotalResultViewModel(result: result, locationProvider: locationProvider)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.refreshLocation()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = ThemeColor.bg
        setNavigationBar()

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bindViewModel()
    }

    private func setNavigationBar() {
        title = "消費結果"
        navigationItem.largeTitleDisplayMode = .never

        navigationItem.leftBarButtonItem = .closeButton { [weak self] in self?.didTapClose() }
        navigationItem.rightBarButtonItem = .locationButton { [weak self] in self?.didTapLocation() }
    }

    // MARK: - Binding

    private func bindViewModel() {
        Publishers.CombineLatest(viewModel.$locationDisplayText, viewModel.$isLocationLoading)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    private func didTapClose() {
        handleDismiss()
    }

    private func didTapLocation() {
        showMapLocationPicker()
    }

    // MARK: - Presentation

    private func showMapLocationPicker() {
        let initial = viewModel.initialLocationForMapPicker
        let vc = MapLocationPickerViewController(
            initialAddress: initial.address,
            latitude: initial.latitude,
            longitude: initial.longitude
        )
        vc.onSelect = { [weak self] address, lat, lon in
            self?.viewModel.updateLocationFromMapPicker(address: address, latitude: lat, longitude: lon)
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }

    // MARK: - Dismiss

    private func handleDismiss() {
        dismissedSubject.send(())
        dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension TotalResultViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.rows.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = viewModel.rows[indexPath.item]

        switch row {
        case .amountPerPerson:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AmountPerPersonCell.reuseId, for: indexPath) as! AmountPerPersonCell
            cell.configure(with: viewModel.result)
            return cell
        case .totalBill:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TotalBillCell.reuseId, for: indexPath) as! TotalBillCell
            cell.configure(with: viewModel.result)
            return cell
        case .totalTip:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TotalTipCell.reuseId, for: indexPath) as! TotalTipCell
            cell.configure(with: viewModel.result)
            return cell
        case .bill:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BillCell.reuseId, for: indexPath) as! BillCell
            cell.configure(with: viewModel.result)
            return cell
        case .tip:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TipCell.reuseId, for: indexPath) as! TipCell
            cell.configure(with: viewModel.result)
            return cell
        case .split:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SplitCell.reuseId, for: indexPath) as! SplitCell
            cell.configure(with: viewModel.result)
            return cell
        case .category:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.reuseId, for: indexPath) as! CategoryCell
            cell.configure(with: viewModel.result)
            return cell
        case .location:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LocationCell.reuseId, for: indexPath) as! LocationCell
            cell.configure(locationText: viewModel.locationDisplayText, isLoading: viewModel.isLocationLoading)
            return cell
        case .save:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SaveRecordCell.reuseId, for: indexPath) as! SaveRecordCell
            cell.onTap = { [weak self] in
                guard let self else { return }
                let success = self.viewModel.saveRecord()
                let message = success ? "儲存成功" : "儲存失敗"
                view.showToast(message: message, position: .center, displayDuration: 1) { [weak self] in
                    self?.handleDismiss()
                }
            }
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TotalResultViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let row = viewModel.rows[indexPath.item]
        let width = collectionView.bounds.width - 32

        switch row {
        case .amountPerPerson: return CGSize(width: width, height: 120)
        case .totalBill: return CGSize(width: width, height: 100)
        case .totalTip: return CGSize(width: width, height: 100)
        case .bill: return CGSize(width: width, height: 100)
        case .tip: return CGSize(width: width, height: 100)
        case .split: return CGSize(width: width, height: 100)
        case .category: return CGSize(width: width, height: 100)
        case .location: return CGSize(width: width, height: 100)
        case .save: return CGSize(width: width, height: 64)
        }
    }
}
