//
//  SettingRowCell.swift
//  tip-calculator
//

import UIKit

final class SettingRowCell: UITableViewCell {

    static let reuseId = "SettingRowCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        textLabel?.font = ThemeFont.regular(Ofsize: 16)
        detailTextLabel?.font = ThemeFont.regular(Ofsize: 16)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
