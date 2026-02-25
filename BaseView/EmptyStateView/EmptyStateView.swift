//
//  EmptyStateView.swift
//  tip-calculator
//

import Lottie
import SnapKit
import UIKit

final class EmptyStateView: UIView {

    private let animationView: LottieAnimationView = {
        let view = LottieAnimationView(name: "Not Found", bundle: .main, subdirectory: nil)
        view.loopMode = .loop
        view.contentMode = .scaleAspectFill
        return view
    }()

    let label: UILabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .title3)
        l.backgroundColor = .systemBackground
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 1
        l.layer.cornerRadius = 12
        l.clipsToBounds = true
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        addSubview(animationView)
        addSubview(label)
        animationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.edges.equalToSuperview()
        }
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(72)
        }
    }

    func play() {
        animationView.play()
    }

    func stop() {
        animationView.stop()
    }
}
