//
//  SceneDelegate.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2025/3/27.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        NavigationBarAppearance.apply()
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .light  
        let tabBar = MainTabBarViewController()
        window.rootViewController = tabBar
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {
        Task { @MainActor in
            LocationService.shared.start()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {
        Task { @MainActor in
            LocationService.shared.stop()
        }
    }


}

