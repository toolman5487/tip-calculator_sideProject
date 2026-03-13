//
//  TabBarItem.swift
//  tip-calculator
//

import UIKit

// MARK: - TabIconProvider

struct TabIconProvider: @unchecked Sendable {

    let fallbackImage: UIImage?

    private let factory: @MainActor () -> UIView
    private let selectionHandler: @MainActor (UIView, Bool, UIColor) -> Void

    @MainActor
    func makeView() -> UIView { factory() }

    @MainActor
    func applySelection(to view: UIView, isSelected: Bool, tintColor: UIColor) {
        selectionHandler(view, isSelected, tintColor)
    }

    static func sfSymbol(_ systemName: String) -> TabIconProvider {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: systemName, withConfiguration: config)
        return TabIconProvider(
            fallbackImage: image,
            factory: {
                let iv = UIImageView(image: image)
                iv.contentMode = .scaleAspectFit
                iv.tintColor = TabBarAppearance.normalColor
                return iv
            },
            selectionHandler: { view, isSelected, tintColor in
                (view as? UIImageView)?.tintColor = isSelected ? tintColor : TabBarAppearance.normalColor
            }
        )
    }

    static func custom(
        fallbackImage: UIImage? = nil,
        makeView: @escaping @MainActor () -> UIView,
        onSelection: @escaping @MainActor (UIView, Bool, UIColor) -> Void = { _, _, _ in }
    ) -> TabIconProvider {
        TabIconProvider(fallbackImage: fallbackImage, factory: makeView, selectionHandler: onSelection)
    }

    private init(
        fallbackImage: UIImage?,
        factory: @escaping @MainActor () -> UIView,
        selectionHandler: @escaping @MainActor (UIView, Bool, UIColor) -> Void
    ) {
        self.fallbackImage = fallbackImage
        self.factory = factory
        self.selectionHandler = selectionHandler
    }
}

// MARK: - TabItemConfig

struct TabItemConfig {
    let title: String
    let iconProvider: TabIconProvider
    let selectedTintColor: UIColor?
    let badgeAnimation: TabBarAnimationStyle
    let preferredIconSize: CGFloat?
}

// MARK: - Display Mode

enum TabBarDisplayMode: Equatable, Sendable {
    case iconOnly
    case iconWithText
}

// MARK: - Animation

enum TabBarAnimationKind: Equatable, Sendable {
    case pulse
}

enum TabBarAnimationStyle: Equatable, Sendable {
    case none
    case animated(TabBarAnimationKind)
}

// MARK: - TabBarItem

struct TabBarItem: @unchecked Sendable {
    let title: String
    let iconProvider: TabIconProvider
    let displayMode: TabBarDisplayMode
    let animationStyle: TabBarAnimationStyle
    let selectedTintColor: UIColor?
    let preferredIconSize: CGFloat?

    init(from config: TabItemConfig, displayMode: TabBarDisplayMode = .iconOnly) {
        self.title = config.title
        self.iconProvider = config.iconProvider
        self.displayMode = displayMode
        self.animationStyle = config.badgeAnimation
        self.selectedTintColor = config.selectedTintColor
        self.preferredIconSize = config.preferredIconSize
    }
}

extension TabBarItem: Equatable {
    static func == (lhs: TabBarItem, rhs: TabBarItem) -> Bool {
        lhs.title == rhs.title && lhs.displayMode == rhs.displayMode && lhs.animationStyle == rhs.animationStyle
    }
}
