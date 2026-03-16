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

    let id: Id
    let title: String
    let detail: String?

    init(id: Id, title: String, detail: String? = nil) {
        self.id = id
        self.title = title
        self.detail = detail
    }
}
