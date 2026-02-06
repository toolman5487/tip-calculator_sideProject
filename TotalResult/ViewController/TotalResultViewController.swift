//
//  TotalResultViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import Foundation
import UIKit
import SnapKit
import Combine
import CoreLocation

@MainActor
final class TotalResultViewController: UIViewController {

    private let viewModel: TotalResultViewModel
    private let dismissedSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    var dismissedPublisher: AnyPublisher<Void, Never> {
        dismissedSubject.eraseToAnyPublisher()
    }
    var onDismiss: (() -> Void)?

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
        collection.register(LocationCell.self, forCellWithReuseIdentifier: LocationCell.reuseId)
        collection.register(SaveRecordCell.self, forCellWithReuseIdentifier: SaveRecordCell.reuseId)
        return collection
    }()

    init(result: Result) {
        let apiKey = Bundle.main.infoDictionary?["GoogleGeocodingAPIKey"] as? String
        let googleService = (apiKey?.isEmpty == false) ? GoogleGeocodingService(apiKey: apiKey!) : nil
        self.viewModel = TotalResultViewModel(result: result, googleGeocodingService: googleService)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "消費結果"
        view.backgroundColor = ThemeColor.bg
        setupNavigation()
        bindViewModel()

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupNavigation() {
        let locationItem = UIBarButtonItem(
            image: UIImage(systemName: "location.fill"),
            style: .plain,
            target: self,
            action: #selector(didTapLocation)
        )
        navigationItem.rightBarButtonItem = locationItem
    }

    private func bindViewModel() {
        Publishers.CombineLatest(viewModel.$locationDisplayText, viewModel.$isLocationLoading)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }

    @objc private func didTapLocation() {
        viewModel.refreshLocation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.refreshLocation()
    }

    private func handleDismiss() {
        dismissedSubject.send(())
        dismiss(animated: true)
    }
}

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
        case .location:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LocationCell.reuseId, for: indexPath) as! LocationCell
            cell.configure(locationText: viewModel.locationDisplayText, isLoading: viewModel.isLocationLoading)
            return cell
        case .save:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SaveRecordCell.reuseId, for: indexPath) as! SaveRecordCell
            cell.onTap = { [weak self] in
                guard let self else { return }
                let loc = LocationService.shared.lastLocation
                let success = self.viewModel.saveRecord(
                    latitude: loc?.coordinate.latitude,
                    longitude: loc?.coordinate.longitude
                )
                if success {
                    ToastView.show(
                        message: "儲存成功",
                        in: self.view,
                        autoDismissAfter: 1
                    ) { [weak self] in
                        self?.handleDismiss()
                    }
                } else {
                    ToastView.show(
                        message: "儲存失敗",
                        in: self.view,
                        autoDismissAfter: 1,
                        systemImageName: "square.and.arrow.down.badge.xmark",
                        tintColor: .systemRed
                    ) { [weak self] in
                        self?.handleDismiss()
                    }
                }
            }
            return cell
        }
    }
}

extension TotalResultViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let row = viewModel.rows[indexPath.item]
        let width = collectionView.bounds.width - 32
        
        switch row {
        case .amountPerPerson:
            return CGSize(width: width, height: 120)
        case .totalBill:
            return CGSize(width: width, height: 100)
        case .totalTip:
            return CGSize(width: width, height: 100)
        case .bill:
            return CGSize(width: width, height: 100)
        case .tip:
            return CGSize(width: width, height: 100)
        case .split:
            return CGSize(width: width, height: 100)
        case .location:
            return CGSize(width: width, height: 100)
        case .save:
            return CGSize(width: width, height: 64)
        }
    }
}
