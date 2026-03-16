//
//  AppIndicatorViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/16.
//

import Foundation
import UIKit
import SnapKit

@MainActor
final class AppIndicatorViewController: BaseViewController {

    // MARK: - Models

    private struct Section {
        let title: String?
        let rows: [Row]
    }

    private enum Row {
        case hero(title: String, subtitle: String)
        case text(title: String, body: String)
        case item(title: String, body: String)
    }

    // MARK: - Data

    private lazy var sections: [Section] = makeSections()

    // MARK: - UI Components

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .systemGroupedBackground
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 120
        tv.dataSource = self
        tv.delegate = self
        tv.register(HeroCell.self, forCellReuseIdentifier: HeroCell.reuseId)
        tv.register(TextCell.self, forCellReuseIdentifier: TextCell.reuseId)
        tv.register(ItemCell.self, forCellReuseIdentifier: ItemCell.reuseId)
        return tv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        tableView.reloadData()
    }

    // MARK: - Setup

    override func setupUI() {
        super.setupUI()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupNavigation() {
        title = title ?? "關於 App"
    }

    private func makeSections() -> [Section] {
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "Tip Calculator"

        return [
            Section(
                title: nil,
                rows: [
                    .hero(
                        title: appName,
                        subtitle: "這是一個把消費計算、地點紀錄、歷史查詢與統計分析整合在一起的工具，適合用來快速記錄每一筆聚餐、外食或日常支出。"
                    )
                ]
            ),
            Section(
                title: "App 介紹",
                rows: [
                    .text(
                        title: "你可以用它做什麼",
                        body: "專案目前由 5 個主要分頁組成，每一頁都對應一段清楚的使用流程。"
                    )
                ]
            ),
            Section(
                title: "核心分頁",
                rows: [
                    .item(title: "用戶總覽", body: "查看個人總消費、分類分布、統計卡片與消費成就。"),
                    .item(title: "資料分析", body: "依時間區間檢視 KPI、消費趨勢、地區統計，並匯出 PDF 報表。"),
                    .item(title: "消費計算機", body: "輸入金額、小費、人數與類別，快速算出每人應付金額。"),
                    .item(title: "消費紀錄", body: "瀏覽歷史紀錄、搜尋、分組查看，進一步進入明細頁。"),
                    .item(title: "設定", body: "調整觸覺回饋、開啟系統設定、查看版本與 App 說明。")
                ]
            ),
            Section(
                title: "建議操作流程",
                rows: [
                    .item(title: "1. 先到消費計算機", body: "輸入帳單金額、選擇消費類別、設定小費與分攤人數。"),
                    .item(title: "2. 送出計算結果", body: "確認每人金額後，進入消費結果頁。"),
                    .item(title: "3. 補上消費地點", body: "系統會嘗試帶入目前位置，也可以手動開地圖搜尋店名或地點。"),
                    .item(title: "4. 儲存成紀錄", body: "儲存後，這筆資料會出現在消費紀錄、資料分析與用戶總覽。"),
                    .item(title: "5. 回頭分析資料", body: "你可以在分析頁看趨勢，在紀錄頁搜尋、分享、編輯或刪除單筆資料。")
                ]
            ),
            Section(
                title: "細部操作",
                rows: [
                    .item(title: "紀錄明細", body: "點進任一消費紀錄後，可以查看金額、分類、時間與地點。"),
                    .item(title: "編輯紀錄", body: "在明細頁可修改日期、金額、小費、人數、分類與地址。"),
                    .item(title: "地點選擇", body: "地圖頁支援手動點選地圖與文字搜尋地點。"),
                    .item(title: "資料分享", body: "分析頁可匯出 PDF，明細頁則可直接分享該筆消費資訊。"),
                    .item(title: "快速刷新", body: "多個主頁面右上角都有刷新按鈕，可重新載入最新資料。")
                ]
            ),
            Section(
                title: "使用提醒",
                rows: [
                    .item(title: "定位權限", body: "如果地點無法自動帶入，可到系統設定開啟定位權限。"),
                    .item(title: "觸覺回饋", body: "設定頁可控制點擊互動時是否啟用震動回饋。"),
                    .item(title: "資料管理", body: "消費紀錄頁提供整批刪除，單筆明細頁也可刪除個別資料。")
                ]
            )
        ]
    }
}

// MARK: - UITableViewDataSource

extension AppIndicatorViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]

        switch row {
        case .hero(let title, let subtitle):
            let cell = tableView.dequeueReusableCell(withIdentifier: HeroCell.reuseId, for: indexPath) as! HeroCell
            cell.configure(title: title, subtitle: subtitle)
            return cell
        case .text(let title, let body):
            let cell = tableView.dequeueReusableCell(withIdentifier: TextCell.reuseId, for: indexPath) as! TextCell
            cell.configure(title: title, body: body)
            return cell
        case .item(let title, let body):
            let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.reuseId, for: indexPath) as! ItemCell
            cell.configure(title: title, body: body)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension AppIndicatorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Cells

private final class HeroCell: UITableViewCell {
    static let reuseId = "HeroCell"

    private let iconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "info.circle.fill"))
        imageView.tintColor = ThemeColor.selected
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.bold(Ofsize: 28)
        label.textColor = ThemeColor.primary
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.regular(Ofsize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .continuous
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    private func setupUI() {
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        iconView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(28)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalTo(iconView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }
    }
}

private final class TextCell: UITableViewCell {
    static let reuseId = "TextCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.bold(Ofsize: 18)
        label.textColor = ThemeColor.primary
        label.numberOfLines = 0
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.regular(Ofsize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, body: String) {
        titleLabel.text = title
        bodyLabel.text = body
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        stack.axis = .vertical
        stack.spacing = 8
        contentView.addSubview(stack)

        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: 4, bottom: 14, right: 4))
        }
    }
}

private final class ItemCell: UITableViewCell {
    static let reuseId = "ItemCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.demiBold(Ofsize: 16)
        label.textColor = ThemeColor.primary
        label.numberOfLines = 0
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.regular(Ofsize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        accessoryType = .none
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, body: String) {
        titleLabel.text = title
        bodyLabel.text = body
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        stack.axis = .vertical
        stack.spacing = 6
        contentView.addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(14)
            make.leading.trailing.equalToSuperview().inset(4)
        }
    }
}
