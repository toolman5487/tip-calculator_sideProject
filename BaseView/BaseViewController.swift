//
//  BaseViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/9.
//

import UIKit
import SnapKit

@MainActor
class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: - Override

    func setupNavigationBar() {
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.largeTitleDisplayMode = .always
    }

    func setupUI() {
        view.backgroundColor = .systemBackground
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
