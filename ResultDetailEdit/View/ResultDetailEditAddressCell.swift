//
//  ResultDetailEditAddressCell.swift
//  tip-calculator
//

import UIKit
import SnapKit

final class ResultDetailEditAddressCell: UITableViewCell {

    static let reuseId = "ResultDetailEditAddressCell"

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
        label.text = "消費地點"
        return label
    }()

    private lazy var textField: UITextField = {
        let field = UITextField()
        field.font = ThemeFont.bold(Ofsize: 16)
        field.textColor = ThemeColor.text
        field.placeholder = "未紀錄"
        field.returnKeyType = .done
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 36))
        toolbar.sizeToFit()
        let done = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), done]
        field.inputAccessoryView = toolbar
        return field
    }()

    var onValueChanged: ((String) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        selectionStyle = .none
        iconImageView.image = UIImage(systemName: "mappin.circle.fill")
        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        iconContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(32)
        }
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            make.centerY.equalTo(iconContainerView)
        }
        textField.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(iconContainerView.snp.bottom).offset(12)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    func configure(value: String) {
        textField.text = value.isEmpty ? "" : value
    }

    @objc private func textFieldDidChange() {
        onValueChanged?(textField.text ?? "")
    }

    @objc private func dismissKeyboard() {
        textField.resignFirstResponder()
    }
}
