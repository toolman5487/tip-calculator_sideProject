//
//  MainIllustrationViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/11.
//

import Foundation
import UIKit
import SnapKit

@MainActor
final class MainIllustrationViewController: MainBaseViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
    }
    
    private func setupNavigation() {
        title = "統計資料"
        let refreshItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshButtonTapped)
        )
        navigationItem.rightBarButtonItem = refreshItem
    }
    
    // MARK: - Actions

    @objc private func refreshButtonTapped() {
        print("Refreshing")
    }
    
}
