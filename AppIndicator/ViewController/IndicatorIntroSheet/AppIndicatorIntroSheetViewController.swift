//
//  AppIndicatorIntroSheetViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/17.
//

import UIKit
import SnapKit

@MainActor
final class AppIndicatorIntroSheetViewController: UIViewController {

    // MARK: - View Model & State

    private let headerTitle: String
    private let introText: String

    // MARK: - UI Components

    private let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = true
        tv.font = ThemeFont.regular(Ofsize: 16)
        tv.textColor = .label
        tv.backgroundColor = .clear
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()

    // MARK: - Initialization

    init(headerTitle: String, introText: String) {
        self.headerTitle = headerTitle
        self.introText = introText
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupIntroSheetContent()
    }

    // MARK: - Setup

    private func setupIntroSheetContent() {
        view.backgroundColor = .systemBackground
        setupNavigation()
        setupTextView()
    }

    private func setupNavigation() {
        let titleLabel = UILabel()
        titleLabel.attributedText = makeTitleAttributedString()
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel

        let config = UIImage.SymbolConfiguration(weight: .bold)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark", withConfiguration: config),
            style: .plain,
            target: self,
            action: #selector(dismissTapped)
        )
    }

    private func setupTextView() {
        textView.text = introText
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }

    // MARK: - Helpers

    private func makeTitleAttributedString() -> NSAttributedString {
        let font = ThemeFont.bold(Ofsize: 20)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        guard let iconImage = UIImage(systemName: "info.circle.fill", withConfiguration: config)?
            .withTintColor(ThemeColor.selected, renderingMode: .alwaysOriginal) else {
            return NSAttributedString(string: headerTitle, attributes: [.font: font, .foregroundColor: ThemeColor.primary])
        }
        let attachment = NSTextAttachment()
        attachment.image = iconImage
        attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -2), size: CGSize(width: 20, height: 20))
        let iconAttr = NSAttributedString(attachment: attachment)
        let spacer = NSAttributedString(string: " ", attributes: [.font: font])
        let textAttr = NSAttributedString(
            string: headerTitle,
            attributes: [.font: font, .foregroundColor: ThemeColor.primary]
        )
        let result = NSMutableAttributedString()
        result.append(iconAttr)
        result.append(spacer)
        result.append(textAttr)
        return result
    }

    // MARK: - Actions

    @objc private func dismissTapped() {
        dismiss(animated: true)
    }
}
