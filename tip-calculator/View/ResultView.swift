//
//  ResultView.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/28.
//

import UIKit

class ResultView: UIView {
    
    private let headerLabel: UILabel = {
        LabelFactory.build(text: "Total p / Person", font: ThemeFont.demiBold(Ofsize: 18))
    }()
    
    private let amountPerPersonLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        let text = NSMutableAttributedString(string: "$0", attributes: [.font:ThemeFont.bold(Ofsize: 48)])
        text.addAttributes([.font: ThemeFont.bold(Ofsize: 24)], range: NSMakeRange(0, 1))
        label.attributedText = text
        return label
    }()
    
    private let horizentalLine:UIView = {
        let view = UIView()
        view.backgroundColor = ThemeColor.seperator
        return view
    }()
    
    private lazy var vStackView:UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            headerLabel,
            amountPerPersonLabel,
            horizentalLine,
            buildSpaceView(height: 0),
            hStackView
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var hStackView:UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            AmountView(title: "Total Bill", textAlignment: .left),
            UIView(),
            AmountView(title: "Total Tip", textAlignment: .right)
        ])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    init(){
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layout(){
        backgroundColor = .white
        addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.top.equalTo(snp.top).offset(24)
            make.bottom.equalTo(snp.bottom).offset(-24)
            make.leading.equalTo(snp.leading).offset(24)
            make.trailing.equalTo(snp.trailing).offset(-24)
        }
        horizentalLine.snp.makeConstraints { make in
            make.height.equalTo(2)
        }
        addShadow(offset: CGSize(width: 0, height: 3),
                  color: UIColor.black,
                  radius: 12.0,
                  opacity: 0.1)
    }
    
    private func buildSpaceView(height:CGFloat) -> UIView {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
    
    
}


