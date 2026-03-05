//
//  ResultDetailEditDatePickerCell.swift
//  tip-calculator
//

import SnapKit
import UIKit

final class ResultDetailEditDatePickerCell: ResultDetailEditBaseCell {

    static let reuseId = "ResultDetailEditDatePickerCell"

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale.autoupdatingCurrent
        return picker
    }()

    var onDateChanged: ((Date) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        titleLabel.text = "消費時間"
        iconImageView.image = UIImage(systemName: "clock")
        contentView.addSubview(datePicker)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)

        datePicker.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }

    func configure(date: Date) {
        datePicker.date = date
    }

    @objc private func datePickerValueChanged() {
        onDateChanged?(datePicker.date)
    }
}
