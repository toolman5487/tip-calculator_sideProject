//
//  BaseBlurSectionHeaderView.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/24.
//

import UIKit
import SnapKit

class BaseBlurSectionHeaderView: UICollectionReusableView {

    var blurStyle: UIBlurEffect.Style { .systemMaterial }

    private(set) lazy var blurView: UIVisualEffectView = {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }()

    var contentView: UIView { blurView.contentView }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setupContent()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupContent() {}
}
