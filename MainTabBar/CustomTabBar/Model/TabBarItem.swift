//
//  TabBarItem.swift
//  tip-calculator
//

import UIKit

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
