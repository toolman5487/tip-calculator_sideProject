//
//  ResultDetailEditAmountCell.swift
//  tip-calculator
//

import SnapKit
import UIKit

final class ResultDetailEditAmountCell: ResultDetailEditBaseCell {

    static let reuseId = "ResultDetailEditAmountCell"

    private lazy var textField: UITextField = {
        let field = UITextField()
        field.font = ThemeFont.bold(Ofsize: 16)
        field.textColor = ThemeColor.text
        field.keyboardType = .decimalPad
        field.textAlignment = .right
        field.placeholder = "0"
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 36))
        toolbar.sizeToFit()
        let done = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), done]
        field.inputAccessoryView = toolbar
        return field
    }()

    var onValueChanged: ((Double) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        titleLabel.text = "帳單金額"
        iconImageView.image = UIImage(systemName: "doc.text.fill")
        contentView.addSubview(textField)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)

        textField.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(80)
        }
    }

    func configure(value: Double) {
        textField.text = value > 0 ? String(format: "%.0f", value) : ""
    }

    @objc private func textFieldDidEndEditing() {
        let value = Double(textField.text ?? "") ?? 0
        onValueChanged?(value)
    }

    @objc private func dismissKeyboard() {
        textField.resignFirstResponder()
    }
}
