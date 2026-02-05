//
//  TotalResultViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import Foundation
import UIKit
import SnapKit

@MainActor
final class TotalResultViewController: UIViewController {

    private let viewModel: TotalResultViewModel

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
        return collection
    }()

    init(result: Result) {
        self.viewModel = TotalResultViewModel(result: result)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Total Result"
        view.backgroundColor = ThemeColor.bg

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
        }
    }
}
