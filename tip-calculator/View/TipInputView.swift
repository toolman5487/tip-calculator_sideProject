//
//  TipInputView.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/28.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit

final class TipInputView: UIView {
    
    private var tipSubject:CurrentValueSubject<Tip, Never> = .init(.none)
    var valuePublisher: AnyPublisher<Tip, Never> {
        return tipSubject.eraseToAnyPublisher()
    }
    private var cancellables = Set<AnyCancellable>()
    private var isFreeSelected = false
    
    private let headerView:HeaderView = {
        let view = HeaderView()
        view.configure(topText: "選擇", bottomText: "小費")
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
        button.accessibilityIdentifier = ScreenIdentifier1.TipInputView.tenPercentButton.rawValue
        button.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                isFreeSelected = false
                switch tipSubject.value {
                case .tenPercent:
                    tipSubject.send(.none)
                default:
                    tipSubject.send(.tenPercent)
                }
            }
            .store(in: &cancellables)
        return button
    }()
    
    private lazy var fifteenPercentTipButton:UIButton = {
        let button = buildTipButton(tip: .fifteenPercent)
        button.accessibilityIdentifier = ScreenIdentifier1.TipInputView.fifteenPercentButton.rawValue
        button.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                isFreeSelected = false
                switch tipSubject.value {
                case .fifteenPercent:
                    tipSubject.send(.none)
                default:
                    tipSubject.send(.fifteenPercent)
                }
            }
            .store(in: &cancellables)
        return button
    }()
    
    private lazy var twentyPercentTipButton:UIButton = {
        let button = buildTipButton(tip: .twentyPercent)
        button.accessibilityIdentifier = ScreenIdentifier1.TipInputView.twentyPercentButton.rawValue
        button.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                isFreeSelected = false
                switch tipSubject.value {
                case .twentyPercent:
                    tipSubject.send(.none)
                default:
                    tipSubject.send(.twentyPercent)
                }
            }
            .store(in: &cancellables)
        return button
    }()
    
    private lazy var freeTipButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = ThemeColor.primary
        button.addCornerRadius(radius: 8.0)
        button.setTitle("Free", for: .normal)
        button.titleLabel?.font = ThemeFont.bold(Ofsize: 20)
        button.setTitleColor(.white, for: .normal)
        button.accessibilityIdentifier = ScreenIdentifier1.TipInputView.freeButton.rawValue
        button.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                if case .none = tipSubject.value, isFreeSelected {
                    isFreeSelected = false
                    tipSubject.send(.none)
                } else {
                    isFreeSelected = true
                    tipSubject.send(.none)
                }
            }
            .store(in: &cancellables)
        return button
    }()
    
    private lazy var customButton:UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setTitle("自訂小費", for: .normal)
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
         freeTipButton,
         customButton
        ].forEach { button in
            button.backgroundColor = ThemeColor.primary
        }
        let text = NSMutableAttributedString(
            string: "自訂小費",
            attributes: [.font: ThemeFont.bold(Ofsize: 20)])
        customButton.setAttributedTitle(text, for: .normal)
    }
    
    private func observe(){
        tipSubject.sink { [weak self] tip in
            guard let self else { return }
            resetView()
            switch tip {
            case .none:
                if isFreeSelected {
                    freeTipButton.backgroundColor = ThemeColor.secondary
                }
            case .tenPercent:
                isFreeSelected = false
                tenPercentTipButton.backgroundColor = ThemeColor.secondary
            case .fifteenPercent:
                isFreeSelected = false
                fifteenPercentTipButton.backgroundColor = ThemeColor.secondary
            case .twentyPercent:
                isFreeSelected = false
                twentyPercentTipButton.backgroundColor = ThemeColor.secondary
            case .custom(value: let value):
                isFreeSelected = false
                customButton.backgroundColor = ThemeColor.secondary
                let text  = NSMutableAttributedString(string: "$\(value)", attributes: [.font:ThemeFont.bold(Ofsize: 20)])
                text.setAttributes([.font:ThemeFont.bold(Ofsize: 14)], range: NSMakeRange(0, 1))
                customButton.setAttributedTitle(text, for: .normal)
            }
        }.store(in: &cancellables)
    }
    
    func tipReset(){
        isFreeSelected = false
        tipSubject.send(.none)
    }
    
    private lazy var buttonHStackView:UIStackView = {
        let hStackView = UIStackView(arrangedSubviews: [
            freeTipButton,
            tenPercentTipButton,
            fifteenPercentTipButton,
            twentyPercentTipButton
        ])
        hStackView.axis = .horizontal
        hStackView.distribution = .fillEqually
        hStackView.spacing = 8
        return hStackView
    }()
    
    private func handleCustomTipButton(){
        let alertController:UIAlertController = {
            let controller = UIAlertController(
                title: "輸入自訂小費",
                message: nil,
                preferredStyle: .alert)
            controller.addTextField { textField in
                textField.placeholder = "請輸入小費金額"
                textField.keyboardType = .decimalPad
                textField.autocorrectionType = .no
                textField.accessibilityIdentifier = ScreenIdentifier1.TipInputView.customTipAlertTextField.rawValue
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel)
            let comfirmAction = UIAlertAction(title: "確認", style: .default){ [weak self] _ in
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
        vStackView.spacing = 8
        return vStackView
    }()
    
    private func layout(){
        [headerView, buttonVStackView].forEach(addSubview(_:))
        
        buttonVStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.trailing.equalToSuperview()
        }

        customButton.snp.makeConstraints { make in
            make.height.equalTo(44)
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
