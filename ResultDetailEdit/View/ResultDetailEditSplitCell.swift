//
//  ResultDetailEditSplitCell.swift
//  tip-calculator
//

import SnapKit
import UIKit

final class ResultDetailEditSplitCell: ResultDetailEditBaseCell {

    static let reuseId = "ResultDetailEditSplitCell"

    private let stepper: UIStepper = {
        let s = UIStepper()
        s.minimumValue = 1
        s.maximumValue = 99
        s.stepValue = 1
        return s
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.bold(Ofsize: 16)
        label.textColor = ThemeColor.text
        return label
    }()

    var onValueChanged: ((Int) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        titleLabel.text = "分攤人數"
        iconImageView.image = UIImage(systemName: "person.3.fill")
        contentView.addSubview(stepper)
        contentView.addSubview(valueLabel)
        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)

        stepper.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        valueLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
            make.trailing.equalTo(stepper.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
        }
    }

    func configure(value: Int) {
        stepper.value = Double(value)
        valueLabel.text = "\(value) 人"
    }

    @objc private func stepperChanged() {
        let value = Int(stepper.value)
        valueLabel.text = "\(value) 人"
        onValueChanged?(value)
    }
}
