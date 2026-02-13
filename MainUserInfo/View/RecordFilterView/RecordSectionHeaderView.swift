//
//  RecordSectionHeaderView.swift
//  tip-calculator
//

import UIKit
import SnapKit

final class RecordSectionHeaderView: UICollectionReusableView {

    static let reuseId = "RecordSectionHeaderView"

    private lazy var blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        return UIVisualEffectView(effect: blur)
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.demiBold(Ofsize: 16)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(blurView)
        addSubview(titleLabel)
        blurView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String) {
        titleLabel.text = title
    }
}
