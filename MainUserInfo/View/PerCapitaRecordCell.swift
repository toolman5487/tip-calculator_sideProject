//
//  PerCapitaRecordCell.swift
//  tip-calculator
//

import UIKit
import SnapKit

final class PerCapitaRecordCell: UICollectionViewCell {

    static let reuseId = "PerCapitaRecordCell"

    // MARK: - UI

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 6
        return view
    }()

    private let titleLabel: UILabel = {
        let label = LabelFactory.build(text: "人均消費", font: ThemeFont.demiBold(Ofsize: 16))
        label.textColor = ThemeColor.text
        return label
    }()

    private let dateLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: ThemeFont.regular(Ofsize: 12))
        label.textColor = .secondaryLabel
        return label
    }()

    private let perCapitaLabel: UILabel = {
        let label = LabelFactory.build(text: "$0", font: ThemeFont.bold(Ofsize: 24))
        label.textColor = ThemeColor.text
        label.textAlignment = .right
        return label
    }()

    private let peopleLabel: UILabel = {
        let label = LabelFactory.build(text: "1 人", font: ThemeFont.regular(Ofsize: 12))
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        return label
    }()

    private let leftStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    private let rightStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .trailing
        stack.spacing = 4
        return stack
    }()

    private let horizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 12
        return stack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.bottom.equalToSuperview().inset(8)
        }

        leftStack.addArrangedSubview(titleLabel)
        leftStack.addArrangedSubview(dateLabel)
        rightStack.addArrangedSubview(perCapitaLabel)
        rightStack.addArrangedSubview(peopleLabel)
        horizontalStack.addArrangedSubview(leftStack)
        horizontalStack.addArrangedSubview(rightStack)

        containerView.addSubview(horizontalStack)
        horizontalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    // MARK: - Configure

    func configure(with viewModel: MainUserInfoViewModel.ItemViewModel) {
        titleLabel.text = viewModel.title
        dateLabel.text = viewModel.dateText
        perCapitaLabel.text = viewModel.perCapitaText
        peopleLabel.text = viewModel.peopleText
    }
}

