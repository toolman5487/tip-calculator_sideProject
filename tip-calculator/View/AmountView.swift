//
//  AmountView.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/29.
//

import Foundation
import UIKit

class AmountView: UIView{
    
    private let title:String
    private let textAlignment:NSTextAlignment
    
    private lazy var titleLabel:UILabel = {
        LabelFactory.build(text: title, font: ThemeFont.regular(Ofsize: 18), textColor: ThemeColor.text, textAlignment: textAlignment)
    }()
    
    private lazy var amountLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = textAlignment
        label.textColor = ThemeColor.primary
        let text  = NSMutableAttributedString(string: "$0", attributes: [.font: ThemeFont.bold(Ofsize: 24)])
        text.addAttributes( [.font: ThemeFont.bold(Ofsize: 24)], range: NSRange(location: 0, length: 1))
        label.attributedText = text
        return label
    }()
    
    private lazy var vStackView:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            amountLabel
        ])
        stack.axis = .vertical
        return stack
    }()
    
    private func layout(){
        addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
   init(title:String, textAlignment:NSTextAlignment){
        self.title = title
        self.textAlignment = textAlignment
        super.init(frame: .zero)
        layout()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
