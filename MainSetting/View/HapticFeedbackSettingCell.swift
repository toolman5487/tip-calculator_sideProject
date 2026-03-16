//
//  HapticFeedbackSettingCell.swift
//  tip-calculator
//

import UIKit

final class HapticFeedbackSettingCell: SettingToggleCell {

    static let cellReuseId = "HapticFeedbackSettingCell"

    func configure(isOn: Bool, onChange: @escaping (Bool) -> Void) {
        configure(title: "觸覺回饋", isOn: isOn, onChange: onChange)
    }
}

