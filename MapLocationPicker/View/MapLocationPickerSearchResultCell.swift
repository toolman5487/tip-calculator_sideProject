//
//  MapLocationPickerSearchResultCell.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/5.
//

import UIKit

final class MapLocationPickerSearchResultCell: UITableViewCell {

    static let reuseId = "MapLocationPickerSearchResultCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: MapLocationPickerSearchResultItem) {
        var config = defaultContentConfiguration()
        config.text = item.title.isEmpty ? item.subtitle : item.title
        config.secondaryText = item.title.isEmpty ? nil : item.subtitle
        config.textProperties.numberOfLines = 1
        config.secondaryTextProperties.numberOfLines = 1
        contentConfiguration = config
    }
}
