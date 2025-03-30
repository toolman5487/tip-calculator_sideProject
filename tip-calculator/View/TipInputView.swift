//
//  TipInputView.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/28.
//

import UIKit

class TipInputView: UIView {
    
    private let headerView:HeaderView = {
        let view = HeaderView()
        view.configure(topText: "Choose", bottomText: "your tip")
        return view
    }()
    
    private func buildTipButton(tip:Tip) -> UIButton{
        let button = UIButton(type: .custom)
        button.backgroundColor = ThemeColor.primary
        button.addCornerRadius(radius: 8.0)
        let text = NSMutableAttributedString(string: tip.stringValue, attributes: [
            .font: ThemeFont.bold(Ofsize: 20),
            .foregroundColor: UIColor.white
        ])
        text.addAttributes([
            .font: ThemeFont.demiBold(Ofsize: 14)
        ], range: NSMakeRange(2, 1))
        button.setAttributedTitle(text, for: .normal)
        return button
    }
    
    private lazy var tenPercentTipButton:UIButton = {
      let button = buildTipButton(tip: .tenPercent)
        return button
    }()
    
    private lazy var fifteenPercentTipButton:UIButton = {
        let button = buildTipButton(tip: .fifteenPercent)
        return button
    }()
    
    private lazy var twentyPercentTipButton:UIButton = {
        let button = buildTipButton(tip: .twentyPercent)
        return button
    }()
    
    private lazy var buttonHStackView:UIStackView = {
        let hStackView = UIStackView(arrangedSubviews: [
            tenPercentTipButton,
            fifteenPercentTipButton,
            twentyPercentTipButton
        ])
        hStackView.axis = .horizontal
        hStackView.distribution = .fillEqually
        hStackView.spacing = 16
        return hStackView
    }()
    
    private lazy var customButton:UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setTitle("Custom Tip", for: .normal)
        button.titleLabel?.font = ThemeFont.bold(Ofsize: 20)
        button.backgroundColor = ThemeColor.primary
        button.addCornerRadius(radius: 8.0)
        return button
    }()
    
    private lazy var buttonVStackView:UIStackView = {
        let vStackView = UIStackView(arrangedSubviews: [
            buttonHStackView,
            customButton
        ])
        vStackView.axis = .vertical
        vStackView.spacing = 16
        return vStackView
    }()
    
    private func layout(){
        [headerView, buttonVStackView].forEach(addSubview(_:))
        
        buttonVStackView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
        }
        
        headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(buttonVStackView.snp.leading).offset(-24)
            make.width.equalTo(68)
            make.centerY.equalTo(buttonVStackView.snp.centerY)
        }
    }
    
    init(){
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
