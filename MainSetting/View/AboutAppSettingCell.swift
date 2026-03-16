//
//  AboutAppSettingCell.swift
//  tip-calculator
//

import UIKit

final class AboutAppSettingCell: SettingRowCell {

    static let cellReuseId = "AboutAppSettingCell"

    func configure() {
        configure(title: "關於 App", showsDisclosureIndicator: true)
    }
}

