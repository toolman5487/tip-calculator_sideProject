//
//  ViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/27.
//

import UIKit
import Combine
import SnapKit

class CalculatorVC: UIViewController {
    
    private let logoView = LogoView()
    private let resultView = ResultView()
    private let billInputView = BillInputView()
    private let tipInputView = TipInputView()
    private let splitInputView = SplitInputView()
    
    private let vm = CalculatorVM()
    private var cancellables = Set<AnyCancellable>()
    
    
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
    
    func bind(){
        let input = CalculatorVM.Input(billPublisher: billInputView.valuePublisher,
                                       tipPublisher: tipInputView.valuePublusher,
                                       splitPublisher: Just(5).eraseToAnyPublisher())
        let output = vm.tranform(input: input)
       output.updateViewPublisher.sink { result in
            print(result)
       }.store(in: &cancellables)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        bind()
        // Do any additional setup after loading the view.
    }

   

}

