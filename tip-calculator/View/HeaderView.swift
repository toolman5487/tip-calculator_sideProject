//
//  HeaderView.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/29.
//

import Foundation
import UIKit

class HeaderView:UIView{
    
    private let topLabel:UILabel = {
        LabelFactory.build(
            text: nil,
            font: ThemeFont.bold(Ofsize: 18)
        )
    }()
    
    private let bottomLabel:UILabel = {
        LabelFactory.build(
            text: nil,
            font: ThemeFont.regular(Ofsize: 16)
        )
    }()
    
    private let topSpacerView = UIView()
    private let bottomSpacerView = UIView()
    
    private lazy var stackView:UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            topSpacerView,
            topLabel,
            bottomLabel,
            bottomSpacerView
        ])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = -4
        return stackView
    }()
    
    private func layout(){
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        topSpacerView.snp.makeConstraints { make in
            make.height.equalTo(bottomSpacerView)
        }
    }
    
    func configure(topText:String, bottomText:String){
        topLabel.text = topText
        bottomLabel.text = bottomText
    }
    
    init() {
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
