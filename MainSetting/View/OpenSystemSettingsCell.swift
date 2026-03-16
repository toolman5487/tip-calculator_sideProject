//
//  OpenSystemSettingsCell.swift
//  tip-calculator
//

import UIKit

final class OpenSystemSettingsCell: SettingRowCell {

    static let cellReuseId = "OpenSystemSettingsCell"

    func configure() {
        configure(title: "在系統設定中開啟", showsDisclosureIndicator: true)
    }
}

