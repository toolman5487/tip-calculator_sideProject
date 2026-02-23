//
//  CategoryPickerSheetViewController.swift
//  tip-calculator
//

import UIKit

@MainActor
final class CategoryPickerSheetViewController: BaseViewController {

    var onSelect: ((Category) -> Void)?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupUI() {
        super.setupUI()
        view.backgroundColor = ThemeColor.bg
    }
}
