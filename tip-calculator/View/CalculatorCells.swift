//
//  CalculatorCells.swift
//  tip-calculator
//

import UIKit
import SnapKit

private let cellInsetHorizontal: CGFloat = 16
private let cellInsetVertical: CGFloat = 8
private var cellContentInsets: UIEdgeInsets {
    UIEdgeInsets(top: cellInsetVertical, left: cellInsetHorizontal, bottom: cellInsetVertical, right: cellInsetHorizontal)
}

// MARK: - ResultCell
final class ResultCell: UITableViewCell {
    static let reuseId = "ResultCell"
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private(set) lazy var resultView = ResultView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupView() {
        contentView.addSubview(containerView)
        containerView.addSubview(resultView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
        resultView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.right.left.bottom.equalToSuperview()
        }
    }

    func configure() {}
}

// MARK: - CategoriesInputCell
final class CategoriesInputCell: UITableViewCell {
    static let reuseId = "CategoriesInputCell"

    enum Category: Int, CaseIterable {
        case food
        case clothing
        case housing
        case transport
        case education
        case entertainment

        var title: String {
            switch self {
            case .food: return "食"
            case .clothing: return "衣"
            case .housing: return "住"
            case .transport: return "行"
            case .education: return "育"
            case .entertainment: return "樂"
            }
        }
    }

    var onCategoryTap: ((Category) -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let headerView: HeaderView = {
        let view = HeaderView()
        view.configure(topText: "選擇", bottomText: "消費種類")
        return view
    }()

    private let columnCount: CGFloat = 3
    private let spacing: CGFloat = 8
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(CategoryItemCell.self, forCellWithReuseIdentifier: CategoryItemCell.reuseId)
        return cv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupView() {
        contentView.addSubview(containerView)
        containerView.addSubview(headerView)
        containerView.addSubview(collectionView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
        headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.width.equalTo(68)
            make.centerY.equalToSuperview()
        }
        collectionView.snp.makeConstraints { make in
            make.leading.equalTo(headerView.snp.trailing).offset(24)
            make.top.bottom.trailing.equalToSuperview().inset(12)
        }
    }

    func configure() {}
}

// MARK: - CategoryItemCell
private final class CategoryItemCell: UICollectionViewCell {
    static let reuseId = "CategoryItemCell"
    private let label: UILabel = {
        let l = UILabel()
        l.font = ThemeFont.bold(Ofsize: 20)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = ThemeColor.primary
        contentView.addCornerRadius(radius: 8)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String) {
        label.text = title
    }
}

// MARK: - CategoriesInputCell + UICollectionView
extension CategoriesInputCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Category.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryItemCell.reuseId, for: indexPath) as! CategoryItemCell
        let category = Category(rawValue: indexPath.item) ?? .food
        cell.configure(title: category.title)
        return cell
    }
}

extension CategoriesInputCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = spacing * (columnCount - 1)
        let w = max(1, collectionView.bounds.width)
        let h = max(1, collectionView.bounds.height)
        let itemWidth = (w - totalSpacing) / columnCount
        let itemHeight = (h - spacing) / 2
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let category = Category(rawValue: indexPath.item) else { return }
        onCategoryTap?(category)
    }
}

// MARK: - TipInputCell
final class TipInputCell: UITableViewCell {
    static let reuseId = "TipInputCell"
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    private(set) lazy var tipInputView = TipInputView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupView() {
        contentView.addSubview(containerView)
        containerView.addSubview(tipInputView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
        tipInputView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    func configure() {}
}

// MARK: - SplitInputCell
final class SplitInputCell: UITableViewCell {
    static let reuseId = "SplitInputCell"
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    private(set) lazy var splitInputView = SplitInputView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupView() {
        contentView.addSubview(containerView)
        containerView.addSubview(splitInputView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
        splitInputView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
    }

    func configure() {}
}

// MARK: - ConfirmButtonCell
final class ConfirmButtonCell: UITableViewCell {
    static let reuseId = "ConfirmButtonCell"
    
    var onTap: (() -> Void)?
    
    private(set) lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("確認", for: .normal)
        button.titleLabel?.font = ThemeFont.bold(Ofsize: 18)
        button.backgroundColor = ThemeColor.secondary
        button.setTitleColor(.white, for: .normal)
        button.addCornerRadius(radius: 8)
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        setupView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupView() {
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(cellContentInsets)
        }
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    }

    func configure() {}
    
    @objc private func didTapConfirm() {
        onTap?()
    }
}
