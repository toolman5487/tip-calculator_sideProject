//
//  LogoView.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/28.
//

import UIKit

class LogoView: UIView {
    
    private let imageView: UIImageView = {
        let view = UIImageView(image: .init(named: "icCalculatorBW"))
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let topLabel:UILabel = {
        let label = UILabel()
        let text = NSMutableAttributedString(string: "MR TIP", attributes: [.font:ThemeFont.demiBold(Ofsize: 16), .foregroundColor: UIColor.black  ])
        text.addAttributes([.font:ThemeFont.bold(Ofsize: 24)], range: NSMakeRange(3, 3))
        label.attributedText = text
        return label
    }()
    
    private let buttomLabel:UILabel = {
        LabelFactory.build(text: "消費計算機", font: ThemeFont.demiBold(Ofsize: 20), textAlignment: .left)
    }()
    
    private lazy var vStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            topLabel,
            buttomLabel
        ])
        view.axis = .vertical
        view.spacing = -4
        return view
    }()
    
    
    private lazy var hStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            imageView,
            vStackView
        ])
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .center
        return view
    }()
    
    init(){
        super.init(frame: .zero)
        accessibilityIdentifier = ScreenIdentifier1.logoView.logoView.rawValue
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout(){
        addSubview(hStackView)
        hStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.height.equalTo(imageView.snp.width)
        }
    }
}

