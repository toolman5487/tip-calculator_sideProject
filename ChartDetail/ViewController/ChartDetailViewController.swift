//
//  ChartDetailViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/13.
//

import UIKit

enum ChartDetailItem {
    case timeChart(title: String, timeFilter: IllustrationTimeFilterOption, records: [ConsumptionRecord])
    case amountRangeChart(title: String, records: [ConsumptionRecord])
}

@MainActor
final class ChartDetailViewController: MainBaseViewController {

    private let detailItem: ChartDetailItem

    init(detailItem: ChartDetailItem) {
        self.detailItem = detailItem
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigationItem.largeTitleDisplayMode = .never
        switch detailItem {
        case .timeChart(let title, _, _), .amountRangeChart(let title, _):
            self.title = title
        }
    }

    override func setupUI() {
        super.setupUI()
        view.backgroundColor = .systemGroupedBackground
        collectionView.backgroundColor = .clear
    }
}
