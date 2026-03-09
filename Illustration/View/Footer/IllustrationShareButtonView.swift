//
//  IllustrationShareButtonView.swift
//  tip-calculator
//

import SnapKit
import UIKit

final class IllustrationShareButtonView: UIView {

    private let button: UIButton = {
        let b = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        b.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: config), for: .normal)
        b.tintColor = .systemBackground
        b.backgroundColor = ThemeColor.selected
        b.addCornerRadius(radius: 8)
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        button.addTarget(target, action: action, for: controlEvents)
    }
}
