//
//  BillInputView.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/28.
//

import UIKit
import Combine
import CombineCocoa

class BillInputView: UIView {
    
    private var cancellables = Set<AnyCancellable>()
    private let billSubject:PassthroughSubject<Double,Never> = .init()
    var valuePublisher:AnyPublisher<Double,Never>{
        return billSubject.eraseToAnyPublisher()
    }
    private var privateText:String?
    var publicText:String?{
        return privateText
    }
    
    private let headerView:HeaderView = {
        let view = HeaderView()
        view.configure(topText: "Enter", bottomText: "your bill")
        return view
    }()
    
    private let textFieldContainView:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addCornerRadius(radius: 8.0)
        return view
        
    }()
    
    private let currencyDenominationLabel:UILabel = {
        let label = LabelFactory.build(text: "$", font: ThemeFont.bold(Ofsize: 24))
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private lazy var textField:UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.font = ThemeFont.demiBold(Ofsize: 28)
        textField.keyboardType = .decimalPad
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.tintColor = ThemeColor.text
        textField.textColor = ThemeColor.text
        
        //add toolbar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 36))
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        
        //add button
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTapped))
        toolbar.items = [
            UIBarButtonItem(
                barButtonSystemItem: .flexibleSpace,
                target: nil,
                action: nil),
            doneButton
        ]
        toolbar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolbar
        return textField
        
    }()
    
    @objc private func doneButtonTapped(){
        textField.endEditing(true)
    }
    
    
    private func layout(){
        [headerView, textFieldContainView].forEach(addSubview(_:))
        
        headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalTo(textFieldContainView.snp.centerY)
            make.width.equalTo(68)
            make.height.equalTo(30)
            make.trailing.equalTo(textFieldContainView.snp.leading).offset(-24)
        }
        
        textFieldContainView.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
        }
        
        textFieldContainView.addSubview(currencyDenominationLabel)
        textFieldContainView.addSubview(textField)
        
        currencyDenominationLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(textFieldContainView.snp.leading).offset(16)
        }
        
        textField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(currencyDenominationLabel.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
    private func observe(){
        textField.textPublisher.sink { [unowned self] text in
            billSubject.send(text?.doubleString ?? 0)
            print("Text: \(text)")
        }.store(in: &cancellables)
    }
    
    init(){
        super.init(frame: .zero)
        layout()
        observe()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


