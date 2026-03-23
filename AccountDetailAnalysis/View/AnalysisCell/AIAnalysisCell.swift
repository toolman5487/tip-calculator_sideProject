//
//  AIAnalysisCell.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/23.
//

import SnapKit
import UIKit

final class AIAnalysisCell: UICollectionViewCell {

    // MARK: - Static

    static let reuseId = "AIAnalysisCell"

    // MARK: - UI Components

    private let loadingContainerView = UIView()

    private let loadingIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .medium)
        v.hidesWhenStopped = true
        return v
    }()

    private let loadingLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeFont.regular(Ofsize: 16)
        l.textColor = .secondaryLabel
        return l
    }()

    private let resultTextView: UITextView = {
        let tv = UITextView()
        tv.font = ThemeFont.regular(Ofsize: 16)
        tv.textColor = ThemeColor.text
        tv.isEditable = false
        tv.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        tv.textContainer.lineFragmentPadding = 0
        tv.backgroundColor = .clear
        return tv
    }()

    private let messageLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeFont.regular(Ofsize: 16)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(loadingContainerView)
        loadingContainerView.addSubview(loadingIndicator)
        loadingContainerView.addSubview(loadingLabel)
        contentView.addSubview(resultTextView)
        contentView.addSubview(messageLabel)

        loadingContainerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        loadingLabel.snp.makeConstraints { make in
            make.top.equalTo(loadingIndicator.snp.bottom).offset(12)
            make.bottom.centerX.equalToSuperview()
        }

        resultTextView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        messageLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(state: AccountDetailAnalysisState, filterTitle: String? = nil) {
        switch state {
        case .idle:
            loadingIndicator.stopAnimating()
            loadingContainerView.isHidden = true
            resultTextView.isHidden = true
            messageLabel.isHidden = true
        case .loading:
            loadingIndicator.startAnimating()
            loadingContainerView.isHidden = false
            loadingLabel.text = (filterTitle ?? "") + "分析中"
            resultTextView.isHidden = true
            messageLabel.isHidden = true
        case .loaded(let text):
            loadingIndicator.stopAnimating()
            loadingContainerView.isHidden = true
            resultTextView.isHidden = false
            resultTextView.text = text
            messageLabel.isHidden = true
        case .unavailable(let message), .error(let message):
            loadingIndicator.stopAnimating()
            loadingContainerView.isHidden = true
            resultTextView.isHidden = true
            messageLabel.isHidden = false
            messageLabel.text = message
        }
    }
}
