//
//  ViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/27.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit

class CalculatorVC: UIViewController {
    
    private let logoView = LogoView()
    private let resultView = ResultView()
    private let billInputView = BillInputView()
    private let tipInputView = TipInputView()
    private let splitInputView = SplitInputView()
    
    private let vm = CalculatorVM()
    private var cancellables = Set<AnyCancellable>()
    private lazy var viewTapPublisher: AnyPublisher<Void,Never> = {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        view.addGestureRecognizer(tapGesture)
        return tapGesture.tapPublisher.flatMap { _ in
            Just(())
        }.eraseToAnyPublisher()
    }()
    
    private lazy var logoViewTapPublisher: AnyPublisher<Void,Never> = {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.numberOfTapsRequired = 2
        logoView.addGestureRecognizer(tapGesture)
        return tapGesture.tapPublisher.flatMap { _ in
            Just(())
        }.eraseToAnyPublisher()
    }()
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            logoView,
            resultView,
            billInputView,
            tipInputView,
            splitInputView,
            UIView()
        ])
        stackView.axis = .vertical
        stackView.spacing = 36
        return stackView
    }()
    
    private func observe(){
        viewTapPublisher.sink { [unowned self] _ in
            view.endEditing(true)
        }.store(in: &cancellables)
        
        logoViewTapPublisher.sink { _ in
            print("Logo is tapped")
        }.store(in: &cancellables)
    }
    
    func bind(){
        let input = CalculatorVM.Input(
            billPublisher: billInputView.valuePublisher,
            tipPublisher: tipInputView.valuePublusher,
            splitPublisher: splitInputView.valuePublisher,
            logoViewTapPulisher: logoViewTapPublisher)
        
        let output = vm.tranform(input: input)
        output.updateViewPublisher.sink { [unowned self] result in
            resultView.configure(result: result)
        }.store(in: &cancellables)
        
        output.resetCalculatorPublisher.sink { [unowned self] _ in
            print("Reset the form!")
            billInputView.billReset()
            tipInputView.tipReset()
            splitInputView.splitReset()
            
            UIView.animate(
                withDuration: 0.1,
                delay: 0,
                usingSpringWithDamping: 5.0,
                initialSpringVelocity: 0.5,
                options: .curveEaseInOut){
                    self.logoView.transform = .init(scaleX: 1.5, y: 1.5)
                } completion: { _ in
                    UIView.animate(withDuration: 0.1) {
                        self.logoView.transform = .identity
                    }
                }
        }.store(in: &cancellables)
    }
    
    private func layout(){
        view.backgroundColor = ThemeColor.bg
        view.addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.leading.equalTo(view.snp_leadingMargin).offset(16)
            make.trailing.equalTo(view.snp_trailingMargin).offset(-16)
            make.top.equalTo(view.snp_topMargin).offset(16)
            make.bottom.equalTo(view.snp_bottomMargin).offset(-16)
        }
        
        logoView.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
        resultView.snp.makeConstraints { make in
            make.height.equalTo(224)
        }
        billInputView.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        tipInputView.snp.makeConstraints { make in
            make.height.equalTo(56+56+15)
        }
        splitInputView.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        bind()
        observe()
        // Do any additional setup after loading the view.
    }
    
    
    
}

