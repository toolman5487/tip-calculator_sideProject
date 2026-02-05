//
//  BaseResultInfoCell.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import Foundation
import UIKit
import SnapKit

class BaseResultInfoCell: UICollectionViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.regular(Ofsize: 16)
        label.textColor = ThemeColor.text
        label.textAlignment = .center
        return label
    }()

    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeColor.seperator
        return view
    }()

    let valueLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.bold(Ofsize: 20)
        label.textColor = ThemeColor.text
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(separatorView)
        containerView.addSubview(valueLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }

        separatorView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(12)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

