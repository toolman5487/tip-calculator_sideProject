//
//  SplitInputView.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/28.
//

import UIKit
import Combine
import SnapKit

class SplitInputView: UIView {
    
    private let controlHeight: CGFloat = 48
    
    private let splitSubject:CurrentValueSubject<Int,Never> = .init(1)
    var valuePublisher:AnyPublisher<Int,Never> {
        return splitSubject.eraseToAnyPublisher()
    }
    private var cancellables = Set<AnyCancellable>()
    
    private let headerView:HeaderView = {
        let view = HeaderView()
        view.configure(topText: "Split", bottomText: "the total")
        return view
    }()
    
    private func buildButton(text:String,corners:CACornerMask)->UIButton{
        let button = UIButton()
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = ThemeFont.bold(Ofsize: 20)
        button.backgroundColor = ThemeColor.primary
        button.addRoundedCorners(corners: corners, radius: 8.0)
        return button
    }
    
    private lazy var decrementButton:UIButton = {
        let button = buildButton(text: "-", corners: [.layerMinXMaxYCorner, .layerMinXMinYCorner])
        button.accessibilityIdentifier = ScreenIdentifier1.SplitInputView.decreaseButton.rawValue
        button.tapPublisher.flatMap { [weak self] _ in
            guard let self else { return Empty<Int, Never>().eraseToAnyPublisher() }
            return Just(self.splitSubject.value == 1 ? 1 : self.splitSubject.value - 1).eraseToAnyPublisher()
        }.assign(to: \.value, on: splitSubject)
            .store(in: &cancellables)
        return button
    }()
    
    private lazy var incrementButton:UIButton = {
        let button = buildButton(text: "+", corners: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
        button.accessibilityIdentifier = ScreenIdentifier1.SplitInputView.increaseButton.rawValue
        button.tapPublisher.flatMap { [weak self] _ in
            guard let self else { return Empty<Int, Never>().eraseToAnyPublisher() }
            return Just(self.splitSubject.value + 1).eraseToAnyPublisher()
        }.assign(to: \.value, on: splitSubject)
            .store(in: &cancellables)
        return button
    }()
    
    private lazy var quantityLabel:UILabel = {
        let label = LabelFactory.build(text: "1", font: ThemeFont.bold(Ofsize: 20),backgroundColor: .white)
        label.accessibilityIdentifier = ScreenIdentifier1.SplitInputView.quantityValueLabel.rawValue
        return label
    }()
    
    private lazy var stackView:UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [decrementButton,quantityLabel,incrementButton])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .center
        return stackView
    }()
    
    private func observe(){
        splitSubject.sink { [weak self] quantity in
            self?.quantityLabel.text = quantity.stringValue
        }.store(in: &cancellables)
    }
    
    func splitReset(){
        splitSubject.send(1)
    }
    
    private func layout(){
        [headerView, stackView].forEach(addSubview(_:))
        
        stackView.snp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
            make.height.equalTo(controlHeight)
        }
        quantityLabel.snp.makeConstraints { make in
            make.height.equalTo(controlHeight)
        }
        [decrementButton,incrementButton].forEach { button in
            button.snp.makeConstraints { make in
                make.height.equalTo(controlHeight)
                make.width.equalTo(controlHeight)
            }
        }
        headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalTo(stackView.snp.centerY)
            make.trailing.equalTo(stackView.snp.leading).offset(-24)
            make.width.equalTo(68)
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

