//
//  MainSettingViewModel.swift
//  tip-calculator
//

import Foundation

enum SettingKeys {
    static let hapticEnabled = "SettingKeys.hapticEnabled"

    static var isHapticEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: hapticEnabled) == nil { return true }
            return UserDefaults.standard.bool(forKey: hapticEnabled)
        }
        set { UserDefaults.standard.set(newValue, forKey: hapticEnabled) }
    }
}

@MainActor
final class MainSettingViewModel {

    private(set) var items: [SettingItem] = []

    func load() {
        items = [
            SettingItem(id: .hapticFeedback, title: "觸覺回饋"),
            SettingItem(id: .about, title: "關於 App"),
            SettingItem(id: .openSystemSettings, title: "在系統設定中開啟"),
            SettingItem(id: .version, title: "版本", detail: appVersion)
        ]
    }

    func item(at index: Int) -> SettingItem? {
        guard index >= 0, index < items.count else { return nil }
        return items[index]
    }

    enum Action {
        case none
        case openSystemSettings
    }

    func action(for id: SettingItem.Id) -> Action {
        switch id {
        case .openSystemSettings: return .openSystemSettings
        case .hapticFeedback, .about, .version: return .none
        }
    }

    func setHapticEnabled(_ value: Bool) {
        SettingKeys.isHapticEnabled = value
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return build.isEmpty ? version : "\(version) (\(build))"
    }
}
