//
//  AccountDetailAnalysisViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/19.
//

import SnapKit
import UIKit

// MARK: -

final class AccountDetailAnalysisViewController: BaseViewController {

    private let viewModel: AccountDetailAnalysisViewModel

    init(recordsText: String) {
        self.viewModel = AccountDetailAnalysisViewModel(recordsText: recordsText)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func setupNavigationBar() {
        title = "AI 智能消費分析"
        navigationItem.largeTitleDisplayMode = .never
    }

    override func setupUI() {
        super.setupUI()
        view.backgroundColor = .systemBackground
    }
}
