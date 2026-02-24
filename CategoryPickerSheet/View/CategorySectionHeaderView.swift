//
//  CategorySectionHeaderView.swift
//  tip-calculator
//

import UIKit
import SnapKit

final class CategorySectionHeaderView: UICollectionReusableView {

    static let reuseId = "CategorySectionHeader"

    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemMaterial)
        let v = UIVisualEffectView(effect: blur)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return v
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.demiBold(Ofsize: 15)
        label.textColor = ThemeColor.text
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(blurView)
        addSubview(titleLabel)
        blurView.frame = bounds
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}
