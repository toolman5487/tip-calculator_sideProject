//
//  AccountDetailShareCell.swift
//  tip-calculator
//

import SnapKit
import UIKit

final class AccountDetailShareCell: UICollectionViewCell {

    static let reuseId = "AccountDetailShareCell"

    var onTap: ((UIView) -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        return view
    }()

    private lazy var shareButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = ThemeColor.selected
        config.baseForegroundColor = .systemBackground
        config.cornerStyle = .medium
        config.image = UIImage(systemName: "square.and.arrow.up")
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)

        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubview(shareButton)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        shareButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(52)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTapShare() {
        onTap?(shareButton)
    }
}
