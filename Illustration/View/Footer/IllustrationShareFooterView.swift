//
//  IllustrationShareFooterView.swift
//  tip-calculator
//

import SnapKit
import UIKit

final class IllustrationShareFooterView: UICollectionReusableView {

    static let reuseId = "IllustrationShareFooterView"

    private let shareButtonView = IllustrationShareButtonView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        addSubview(shareButtonView)
        shareButtonView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(52)
        }
        shareButtonView.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    func configure(onTap: @escaping (UIView) -> Void) {
        onTapHandler = onTap
    }

    private var onTapHandler: ((UIView) -> Void)?

    @objc private func buttonTapped() {
        onTapHandler?(shareButtonView)
    }
}
