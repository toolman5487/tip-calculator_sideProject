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

    static func image(_ image: UIImage) -> TabIconProvider {
        TabIconProvider(
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

    static func sfSymbol(_ systemName: String) -> TabIconProvider {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: systemName, withConfiguration: config)
        return .image(image ?? UIImage())
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
    let id: Int
    let iconProvider: TabIconProvider
    let selectedTintColor: UIColor?
    let badgeAnimation: TabBarAnimationStyle
    let preferredIconSize: CGFloat?
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
    let id: Int
    let iconProvider: TabIconProvider
    let animationStyle: TabBarAnimationStyle
    let selectedTintColor: UIColor?
    let preferredIconSize: CGFloat?

    init(from config: TabItemConfig) {
        self.id = config.id
        self.iconProvider = config.iconProvider
        self.animationStyle = config.badgeAnimation
        self.selectedTintColor = config.selectedTintColor
        self.preferredIconSize = config.preferredIconSize
    }
}

extension TabBarItem: Equatable {
    static func == (lhs: TabBarItem, rhs: TabBarItem) -> Bool {
        lhs.id == rhs.id && lhs.animationStyle == rhs.animationStyle
    }
}
