//
//  MainTabBarTab.swift
//  tip-calculator
//

import Lottie
import UIKit

// MARK: - Lottie icon support

extension TabIconProvider {
    static func lottie(_ name: String) -> TabIconProvider {
        .custom(
            fallbackImage: nil,
            makeView: {
                let av = LottieAnimationView(name: name)
                av.contentMode = .scaleAspectFill
                av.loopMode = .loop
                av.isUserInteractionEnabled = false
                av.clipsToBounds = true
                av.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                av.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
                return av
            },
            onSelection: { view, isSelected, tintColor in
                guard let lottie = view as? LottieAnimationView else { return }
                let color = isSelected ? tintColor : TabBarAppearance.normalColor
                let provider = ColorValueProvider(color.lottieColorValue)
                lottie.setValueProvider(provider, keypath: AnimationKeypath(keypath: "**.Color"))
                isSelected ? lottie.play() : lottie.stop()
            }
        )
    }
}

// MARK: - MainTabBarTab

enum MainTabBarTab: CaseIterable {
    case calculator
    case userInfo
    case illustration
    case accountDetail

    var tabItemConfig: TabItemConfig {
        switch self {
        case .calculator:
            return TabItemConfig(
                title: "消費計算",
                iconProvider: .lottie("Calculator"),
                selectedTintColor: TabBarAppearance.selectedColor,
                badgeAnimation: .none,
                preferredIconSize: 48
            )
        case .userInfo:
            return TabItemConfig(
                title: "消費紀錄",
                iconProvider: .sfSymbol("rectangle.stack.fill"),
                selectedTintColor: nil,
                badgeAnimation: .animated(.pulse),
                preferredIconSize: nil
            )
        case .illustration:
            return TabItemConfig(
                title: "資料分析",
                iconProvider: .sfSymbol("chart.bar.fill"),
                selectedTintColor: nil,
                badgeAnimation: .none,
                preferredIconSize: nil
            )
        case .accountDetail:
            return TabItemConfig(
                title: "資料總覽",
                iconProvider: .sfSymbol("square.grid.3x3.fill"),
                selectedTintColor: nil,
                badgeAnimation: .none,
                preferredIconSize: nil
            )
        }
    }

    var title: String { tabItemConfig.title }
    var image: UIImage? { tabItemConfig.iconProvider.fallbackImage }
    var selectedImage: UIImage? { image }

    var viewController: UIViewController {
        switch self {
        case .calculator:
            return NavigationBarAppearance.wrapInNavigationController(rootViewController: CalculatorVC())
        case .userInfo:
            return NavigationBarAppearance.wrapInNavigationController(rootViewController: MainUserInfoViewController())
        case .illustration:
            return NavigationBarAppearance.wrapInNavigationController(rootViewController: MainIllustrationViewController())
        case .accountDetail:
            return NavigationBarAppearance.wrapInNavigationController(rootViewController: MainAccountDetailViewController())
        }
    }

    var tabBarItem: UITabBarItem {
        UITabBarItem(title: title, image: image, selectedImage: selectedImage)
    }

    var customTabBarItem: TabBarItem {
        TabBarItem(from: tabItemConfig)
    }
}
