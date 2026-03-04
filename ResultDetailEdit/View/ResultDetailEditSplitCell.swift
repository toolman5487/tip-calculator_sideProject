//
//  ResultDetailEditSplitCell.swift
//  tip-calculator
//

import UIKit
import SnapKit

final class ResultDetailEditSplitCell: UITableViewCell {

    static let reuseId = "ResultDetailEditSplitCell"

    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.demiBold(Ofsize: 16)
        label.textColor = .secondaryLabel
        label.text = "分攤人數"
        return label
    }()

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
        selectionStyle = .none
        iconImageView.image = UIImage(systemName: "person.3.fill")
        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(stepper)
        contentView.addSubview(valueLabel)
        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)

        iconContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        stepper.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        valueLabel.snp.makeConstraints { make in
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
