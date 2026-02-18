//
//  ChartDetailViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/13.
//

import Foundation
import UIKit
import SnapKit

enum ChartDetailItem {
    case timeChart(title: String)
    case amountRangeChart(title: String)
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
        navigationItem.largeTitleDisplayMode = .never
        switch detailItem {
        case .timeChart(let title),
             .amountRangeChart(let title):
            self.title = title
        }
    }
}
