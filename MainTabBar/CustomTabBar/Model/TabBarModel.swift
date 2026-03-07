//
//  TabBarModel.swift
//  tip-calculator
//

import UIKit

// MARK: - Appearance

enum TabBarAppearance {
    static let selectedColor: UIColor = ThemeColor.selected
    static let normalColor: UIColor = .label
    static let animationPrimaryColor: UIColor = .systemRed
    static let separatorColor: UIColor = .separator
    static let selectionScale: CGFloat = 1.1
    static let animationDuration: TimeInterval = 0.2
    static let pulseScale: CGFloat = 1.15
    static let pulseDuration: TimeInterval = 0.8
}

// MARK: - Display Mode

enum TabBarDisplayMode: Equatable, Sendable {
    case iconOnly
    case iconWithText
}

// MARK: - Animation

enum TabBarAnimationKind: Equatable, Sendable {
    case pulse
    case colorChange
}

enum TabBarAnimationStyle: Equatable, Sendable {
    case none
    case animated(TabBarAnimationKind)
}

// MARK: - Tab Bar Item

struct TabBarItem: Equatable, Sendable {
    let title: String
    let icon: UIImage?
    let selectedIcon: UIImage?
    let displayMode: TabBarDisplayMode
    let animationStyle: TabBarAnimationStyle

    static func == (lhs: TabBarItem, rhs: TabBarItem) -> Bool {
        guard lhs.title == rhs.title && lhs.displayMode == rhs.displayMode && lhs.animationStyle == rhs.animationStyle else {
            return false
        }

        if lhs.icon !== rhs.icon || lhs.selectedIcon !== rhs.selectedIcon {
            return false
        }

        return true
    }

    init(
        title: String,
        iconName: String,
        selectedIconName: String? = nil,
        displayMode: TabBarDisplayMode = .iconWithText,
        animationStyle: TabBarAnimationStyle = .none
    ) {
        self.title = title
        self.icon = UIImage(systemName: iconName)
        self.selectedIcon = selectedIconName.flatMap { UIImage(systemName: $0) } ?? self.icon
        self.displayMode = displayMode
        self.animationStyle = animationStyle
    }

    init(title: String, icon: UIImage?, selectedIcon: UIImage?, displayMode: TabBarDisplayMode = .iconWithText, animationStyle: TabBarAnimationStyle = .none) {
        self.title = title
        self.icon = icon
        self.selectedIcon = selectedIcon ?? icon
        self.displayMode = displayMode
        self.animationStyle = animationStyle
    }
}
