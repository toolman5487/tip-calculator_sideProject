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

    private(set) var sections: [SettingSection] = []

    func load() {
        sections = [
            SettingSection(items: [
                SettingItem(id: .hapticFeedback, title: "觸覺回饋", accessory: .toggle(isOn: SettingKeys.isHapticEnabled))
            ]),
            SettingSection(items: [
                SettingItem(id: .about, title: "關於 App", accessory: .disclosure),
                SettingItem(id: .version, title: "版本", detail: appVersion, accessory: .none),
                SettingItem(id: .openSystemSettings, title: "在系統設定中開啟", accessory: .disclosure)
            ])
        ]
    }

    func item(at indexPath: IndexPath) -> SettingItem? {
        guard indexPath.section >= 0, indexPath.section < sections.count else { return nil }
        let section = sections[indexPath.section]
        guard indexPath.item >= 0, indexPath.item < section.items.count else { return nil }
        return section.items[indexPath.item]
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
