//
//  BaseViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/9.
//

import Combine
import SnapKit
import UIKit

@MainActor
class BaseViewController: UIViewController, UITextFieldDelegate {

    private var keyboardAvoidanceCancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: - Override

    func setupNavigationBar() {
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.largeTitleDisplayMode = .automatic
    }

    func setupUI() {
        view.backgroundColor = .systemBackground
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    func setupKeyboardAvoidance(for scrollView: UIScrollView) {
        scrollView.keyboardDismissMode = .onDrag
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo }
            .receive(on: DispatchQueue.main)
            .sink { userInfo in
                guard scrollView.window != nil,
                      let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                      let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
                UIView.animate(withDuration: duration) {
                    scrollView.contentInset.bottom = frame.height
                    scrollView.verticalScrollIndicatorInsets.bottom = frame.height
                }
            }
            .store(in: &keyboardAvoidanceCancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .compactMap { $0.userInfo }
            .receive(on: DispatchQueue.main)
            .sink { userInfo in
                guard scrollView.window != nil,
                      let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
                UIView.animate(withDuration: duration) {
                    scrollView.contentInset.bottom = 0
                    scrollView.verticalScrollIndicatorInsets.bottom = 0
                }
            }
            .store(in: &keyboardAvoidanceCancellables)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
