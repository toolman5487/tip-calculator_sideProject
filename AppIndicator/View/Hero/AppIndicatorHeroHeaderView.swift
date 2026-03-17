//
//  AppIndicatorHeroHeaderView.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/17.
//

import UIKit
import SnapKit

final class AppIndicatorHeroHeaderView: UICollectionReusableView {
    
    static let reuseId = "AppIndicatorHeroHeaderView"
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let introLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.regular(Ofsize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 4
        return label
    }()
    
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 16
        v.layer.cornerCurve = .continuous
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = true
        addSubview(containerView)
        containerView.addSubview(headerLabel)
        containerView.addSubview(introLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(introLabel.snp.top)
        }
        
        introLabel.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var onTap: (() -> Void)?
    
    func configure(title: String, intro: String, onTap: (() -> Void)? = nil) {
        headerLabel.attributedText = makeHeaderAttributedString(title: title)
        introLabel.text = intro
        self.onTap = onTap
    }
    
    private func makeHeaderAttributedString(title: String) -> NSAttributedString {
        let font = ThemeFont.bold(Ofsize: 28)
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        guard let iconImage = UIImage(systemName: "info.circle.fill", withConfiguration: config)?
            .withTintColor(ThemeColor.selected, renderingMode: .alwaysOriginal) else {
            return NSAttributedString(string: title, attributes: [.font: font, .foregroundColor: ThemeColor.primary])
        }
        let attachment = NSTextAttachment()
        attachment.image = iconImage
        attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -4), size: CGSize(width: 28, height: 28))
        let iconAttr = NSAttributedString(attachment: attachment)
        let spacer = NSAttributedString(string: " ", attributes: [.font: font])
        let textAttr = NSAttributedString(
            string: title,
            attributes: [.font: font, .foregroundColor: ThemeColor.primary]
        )
        let result = NSMutableAttributedString()
        result.append(iconAttr)
        result.append(spacer)
        result.append(textAttr)
        return result
    }
    
    @objc private func handleTap() {
        onTap?()
    }
}
