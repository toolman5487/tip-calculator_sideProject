//
//  TabBarContentTransition.swift
//  tip-calculator
//

import UIKit

enum TabBarContentTransition {
    static func performSlide(
        from fromIndex: Int,
        to toIndex: Int,
        outgoingView: UIView,
        incomingView: UIView,
        containerWidth: CGFloat,
        duration: TimeInterval,
        completion: @escaping () -> Void
    ) {
        let slideRight = toIndex > fromIndex

        incomingView.transform = CGAffineTransform(translationX: slideRight ? containerWidth : -containerWidth, y: 0)

        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut]) {
            outgoingView.transform = CGAffineTransform(translationX: slideRight ? -containerWidth : containerWidth, y: 0)
            incomingView.transform = .identity
        } completion: { _ in
            completion()
        }
    }
}
