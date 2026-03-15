//
//  SettingItem.swift
//  tip-calculator
//

import Foundation

struct SettingSection {
    let items: [SettingItem]
}

struct SettingItem {
    enum Id: String {
        case hapticFeedback
        case about
        case version
        case openSystemSettings
    }

    enum Accessory: Equatable {
        case none
        case disclosure
        case toggle(isOn: Bool)
    }

    let id: Id
    let title: String
    let detail: String?
    let accessory: Accessory

    init(id: Id, title: String, detail: String? = nil, accessory: Accessory = .disclosure) {
        self.id = id
        self.title = title
        self.detail = detail
        self.accessory = accessory
    }
}
