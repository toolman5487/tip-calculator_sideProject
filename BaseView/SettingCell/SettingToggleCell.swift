//
//  SettingToggleCell.swift
//  tip-calculator
//

import SnapKit
import UIKit

class SettingToggleCell: UITableViewCell {

    static let reuseId = "SettingToggleCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.regular(Ofsize: 16)
        label.textColor = .label
        return label
    }()

    private let switchControl: UISwitch = {
        let s = UISwitch()
        return s
    }()

    private var onChange: ((Bool) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchControl)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        switchControl.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onChange = nil
    }

    func configure(title: String, isOn: Bool, onChange: @escaping (Bool) -> Void) {
        titleLabel.text = title
        switchControl.isOn = isOn
        self.onChange = onChange
    }

    @objc private func switchValueChanged() {
        onChange?(switchControl.isOn)
    }
}
