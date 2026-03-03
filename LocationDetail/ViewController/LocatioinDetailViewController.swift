//
//  LocatioinDetailViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/3.
//

import Foundation
import UIKit
import SnapKit

@MainActor
final class LocationDetailViewController: MainBaseViewController {

    private let item: LocationStatItem

    init(item: LocationStatItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = item.name
    }
}
