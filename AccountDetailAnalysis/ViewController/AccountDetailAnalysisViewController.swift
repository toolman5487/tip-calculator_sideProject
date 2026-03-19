//
//  AccountDetailAnalysisViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/19.
//

import Combine
import Foundation
import SnapKit
import UIKit

@MainActor
final class AccountDetailAnalysisViewController: BaseViewController {

    private let viewModel: AccountDetailAnalysisViewModel
    private var cancellables = Set<AnyCancellable>()

    private let loadingIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .large)
        v.hidesWhenStopped = true
        return v
    }()

    private let messageLabel: UILabel = {
        let l = UILabel()
        l.font = ThemeFont.regular(Ofsize: 16)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.textAlignment = .center
        l.isHidden = true
        return l
    }()

    private let resultTextView: UITextView = {
        let tv = UITextView()
        tv.font = ThemeFont.regular(Ofsize: 16)
        tv.textColor = ThemeColor.text
        tv.isEditable = false
        tv.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        tv.backgroundColor = .clear
        tv.isHidden = true
        return tv
    }()

    init(recordsText: String) {
        self.viewModel = AccountDetailAnalysisViewModel(recordsText: recordsText)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.startAnalysis()
    }

    override func setupNavigationBar() {
        title = "智能分析消費"
        navigationItem.largeTitleDisplayMode = .never
    }

    override func setupUI() {
        super.setupUI()
        view.backgroundColor = .systemBackground

        view.addSubview(loadingIndicator)
        view.addSubview(messageLabel)
        view.addSubview(resultTextView)

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        messageLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }

        resultTextView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func bind() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateUI(for: state)
            }
            .store(in: &cancellables)
    }

    private func updateUI(for state: AccountDetailAnalysisState) {
        switch state {
        case .idle:
            loadingIndicator.stopAnimating()
            messageLabel.isHidden = true
            resultTextView.isHidden = true
        case .loading:
            loadingIndicator.startAnimating()
            messageLabel.isHidden = true
            resultTextView.isHidden = true
        case .loaded(let text):
            loadingIndicator.stopAnimating()
            messageLabel.isHidden = true
            resultTextView.isHidden = false
            resultTextView.text = text
        case .unavailable(let message), .error(let message):
            loadingIndicator.stopAnimating()
            messageLabel.isHidden = false
            messageLabel.text = message
            resultTextView.isHidden = true
        }
    }
}
