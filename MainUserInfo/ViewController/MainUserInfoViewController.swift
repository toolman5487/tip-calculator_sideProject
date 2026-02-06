//
//  MainUserInfoViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import UIKit
import SnapKit

@MainActor
final class MainUserInfoViewController: UIViewController {

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: ResultsFilterViewController())
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "搜尋消費紀錄"
        controller.searchBar.searchTextField.backgroundColor = .systemBackground
        controller.searchBar.searchTextField.tintColor = .label
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
    }

    private func setupNavigation() {
        title = "消費紀錄"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
}
