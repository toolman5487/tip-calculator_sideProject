//
//  MainSettingViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/14.
//

import Foundation
import UIKit
import SnapKit

@MainActor
final class MainSettingViewController: MainBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
    }

    private func setupNavigation() {
        title = "設定"
    }
}
