//
//  TipInputView.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/28.
//

import UIKit
import Combine
import CombineCocoa

class TipInputView: UIView {
    
    private var tipSubject:CurrentValueSubject<Tip, Never> = .init(.none)
    var valuePublusher:AnyPublisher<Tip,Never>{
        return tipSubject.eraseToAnyPublisher()
    }
    private var cancellables = Set<AnyCancellable>()
    
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
        //tabPublisher: CombineCocoa
        button.accessibilityIdentifier = ScreenIdentifier1.TipInputView.tenPercentButton.rawValue
        button.tapPublisher.flatMap {
            Just(Tip.tenPercent)
        }.assign(to: \.value, on: tipSubject) // tipSubject.value
            .store(in: &cancellables)
        return button
    }()
    
    private lazy var fifteenPercentTipButton:UIButton = {
        let button = buildTipButton(tip: .fifteenPercent)
        button.accessibilityIdentifier = ScreenIdentifier1.TipInputView.fifteenPercentButton.rawValue
        button.tapPublisher.flatMap {
            Just(Tip.fifteenPercent)
        }.assign(to: \.value, on: tipSubject)
            .store(in: &cancellables)
        return button
    }()
    
    private lazy var twentyPercentTipButton:UIButton = {
        let button = buildTipButton(tip: .twentyPercent)
        button.accessibilityIdentifier = ScreenIdentifier1.TipInputView.twentyPercentButton.rawValue
        button.tapPublisher.flatMap {
            Just(Tip.twentyPercent)
        }.assign(to: \.value, on: tipSubject)
            .store(in: &cancellables)
        return button
    }()
    
    private lazy var customButton:UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setTitle("Custom Tip", for: .normal)
        button.titleLabel?.font = ThemeFont.bold(Ofsize: 20)
        button.backgroundColor = ThemeColor.primary
        button.addCornerRadius(radius: 8.0)
        button.accessibilityIdentifier = ScreenIdentifier1.TipInputView.customTipButton.rawValue
        button.tapPublisher.sink { [weak self]_ in
            self?.handleCustomTipButton()
        }.store(in: &cancellables)
        return button
    }()
    
    private func resetView(){
        [tenPercentTipButton,
         fifteenPercentTipButton,
         twentyPercentTipButton,
         customButton
        ].forEach { button in
            button.backgroundColor = ThemeColor.primary
        }
        let text = NSMutableAttributedString(
            string: "Custom Tip",
            attributes: [.font: ThemeFont.bold(Ofsize: 20)])
        customButton.setAttributedTitle(text, for: .normal)
    }
    
    private func observe(){
        tipSubject.sink { [unowned self] tip in
            resetView()
            switch tip {
            case .none:
                break
            case .tenPercent:
                tenPercentTipButton.backgroundColor = ThemeColor.secondary
            case .fifteenPercent:
                fifteenPercentTipButton.backgroundColor = ThemeColor.secondary
            case .twentyPercent:
                twentyPercentTipButton.backgroundColor = ThemeColor.secondary
            case .custom(value: let value):
                customButton.backgroundColor = ThemeColor.secondary
                let text  = NSMutableAttributedString(string: "$\(value)", attributes: [.font:ThemeFont.bold(Ofsize: 20)])
                text.setAttributes([.font:ThemeFont.bold(Ofsize: 14)], range: NSMakeRange(0, 1))
                customButton.setAttributedTitle(text, for: .normal)
            }
        }.store(in: &cancellables)
    }
    
    func tipReset(){
        tipSubject.send(.none)
    }
    
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
    
    private func handleCustomTipButton(){
        let alertController:UIAlertController = {
            let controller = UIAlertController(
                title: "Enter Custom Tip",
                message: nil,
                preferredStyle: .alert)
            controller.addTextField { textField in
                textField.placeholder = "Make it gorgeous!"
                textField.keyboardType = .decimalPad
                textField.autocorrectionType = .no
                textField.accessibilityIdentifier = ScreenIdentifier1.TipInputView.customTipAlertTextField.rawValue
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let comfirmAction = UIAlertAction(title: "Comfirm", style: .default){ [weak self] _ in
                guard let text = controller.textFields?.first?.text,
                      let value = Int(text) else { return }
                self?.tipSubject.send(.custom(value: value))
            }
            [cancelAction,comfirmAction].forEach(controller.addAction(_:))
            return controller
        }()
        parentViewController?.present(alertController, animated: true)
    }
    
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
        observe()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
