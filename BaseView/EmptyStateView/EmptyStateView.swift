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
        l.backgroundColor = .clear
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    private let labelContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.clipsToBounds = true
        return v
    }()

    private let blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemUltraThinMaterial)
        let v = UIVisualEffectView(effect: effect)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.alpha = 0.9
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = min(labelContainerView.bounds.width, labelContainerView.bounds.height) / 2
        labelContainerView.layer.cornerRadius = radius
    }

    private func setupUI() {
        backgroundColor = .clear
        addSubview(animationView)
        addSubview(labelContainerView)
        labelContainerView.addSubview(blurView)
        labelContainerView.addSubview(label)
        animationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.edges.equalToSuperview()
        }
        labelContainerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(60)
        }
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
    }

    func play() {
        animationView.play()
    }

    func stop() {
        animationView.stop()
    }
}
