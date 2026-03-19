//
//  AccountDetailAIAnalysisCell.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/19.
//

import Foundation
import UIKit
import SnapKit

@MainActor
final class AccountDetailAIAnalysisCell: UICollectionViewCell {

    static let reuseId = "AccountDetailAIAnalysisCell"

    var onTap: (() -> Void)?

    private lazy var button: UIButton = {
        let b = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        b.setImage(UIImage(systemName: "sparkles", withConfiguration: config), for: .normal)
        b.tintColor = .systemBackground
        b.backgroundColor = ThemeColor.selected
        b.layer.cornerRadius = 16
        b.clipsToBounds = true
        b.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.left.right.equalToSuperview().inset(16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func buttonTapped() {
        onTap?()
    }
}
