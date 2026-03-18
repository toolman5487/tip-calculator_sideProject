//
//  AppIndicatorViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/17.
//

import Foundation
import Combine

struct AppIndicatorFilterHeaderViewModel {
    let selectedIndex: Int
    let options: [String]
    let onSelect: (Int) -> Void
}

@MainActor
final class AppIndicatorViewModel {

    static let heroSectionIndex = 0
    static let contentSectionIndex = 1

    @Published private(set) var selectedSectionIndex: Int = 0

    private(set) lazy var sections: [AppIndicatorSection] = makeSections()

    var numberOfSections: Int { 2 }

    func numberOfItems(in section: Int) -> Int {
        switch section {
        case Self.heroSectionIndex: return 0
        case Self.contentSectionIndex: return selectedSectionRows.count
        default: return 0
        }
    }

    func isHeroSection(_ section: Int) -> Bool { section == Self.heroSectionIndex }

    func isContentSection(_ section: Int) -> Bool { section == Self.contentSectionIndex }

    var filterHeaderViewModel: AppIndicatorFilterHeaderViewModel {
        let options = sections.map(\.pillTitle)
        return AppIndicatorFilterHeaderViewModel(
            selectedIndex: selectedSectionIndex,
            options: options,
            onSelect: { [weak self] index in self?.selectSection(at: index) }
        )
    }

    private static let heroHeaderIntroText = [
        "LazyTrack是一款整合消費計算、地點紀錄、歷史查詢與統計分析的個人理財管理工具，其核心功能涵蓋了從即時帳務處理到深度數據剖析的完整流程。",
        "使用者可透過系統內建的計算模組，輸入帳單總額、小費比例與分攤人數，快速試算社交聚餐中個人應付金額，並在建立紀錄時結合自動定位或手動選擇功能，為每筆支出標註精確的地理位置。",
        "在資料檢索維度上，該工具提供了強大的歷史數據查詢系統，支援關鍵字搜尋、多重條件篩選與邏輯分組檢視，方便使用者隨時回溯財務往來細節。",
        "此外，LazyTrack 進一步將紀錄轉化為具備分析價值的資訊，透過關鍵績效指標（KPI）、消費趨勢圖表及地區分布統計，協助使用者精確識別在同事聚餐、親友社交、外食約會或日常開銷等不同生活情境下的支出結構與慣性，實現從精準記錄到量化回顧的個人化財務管理。"
    ].joined(separator: "\n\n")

    lazy var heroHeaderTitle: String = {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "LazyTrack"
    }()

    var heroHeaderIntro: String { Self.heroHeaderIntroText }

    var selectedSectionRows: [AppIndicatorRow] {
        guard selectedSectionIndex >= 0, selectedSectionIndex < sections.count else { return [] }
        return sections[selectedSectionIndex].rows
    }

    func selectSection(at index: Int) {
        guard index >= 0, index < sections.count, index != selectedSectionIndex else { return }
        selectedSectionIndex = index
    }

    func row(at index: Int) -> AppIndicatorRow? {
        let rows = selectedSectionRows
        guard index >= 0, index < rows.count else { return nil }
        return rows[index]
    }

    func mainTabForContentRow(at index: Int) -> MainTabBarTab? {
        guard selectedSectionIndex == 0 else { return nil }
        switch index {
        case 0: return .accountDetail
        case 1: return .illustration
        case 2: return .calculator
        case 3: return .userInfo
        case 4: return .setting
        default: return nil
        }
    }

    private func makeSections() -> [AppIndicatorSection] {
        return [
            AppIndicatorSection(
                pillTitle: "核心分頁",
                rows: [
                    .item(title: "用戶總覽", body: "查看個人總消費、分類分布、統計卡片與消費成就。"),
                    .item(title: "資料分析", body: "依時間區間檢視 KPI、消費趨勢、地區統計，並匯出 PDF 報表。"),
                    .item(title: "消費計算機", body: "輸入金額、小費、人數與類別，快速算出每人應付金額。"),
                    .item(title: "消費紀錄", body: "瀏覽歷史紀錄、搜尋、分組查看，進一步進入明細頁。"),
                    .item(title: "設定", body: "調整觸覺回饋、開啟系統設定、查看版本與 App 說明。")
                ]
            ),
            AppIndicatorSection(
                pillTitle: "建議操作流程",
                rows: [
                    .item(title: "1. 先到消費計算機", body: "輸入帳單金額、選擇消費類別、設定小費與分攤人數。"),
                    .item(title: "2. 送出計算結果", body: "確認每人金額後，進入消費結果頁。"),
                    .item(title: "3. 補上消費地點", body: "系統會嘗試帶入目前位置，也可以手動開地圖搜尋店名或地點。"),
                    .item(title: "4. 儲存成紀錄", body: "儲存後，這筆資料會出現在消費紀錄、資料分析與用戶總覽。"),
                    .item(title: "5. 回頭分析資料", body: "你可以在分析頁看趨勢，在紀錄頁搜尋、分享、編輯或刪除單筆資料。")
                ]
            ),
            AppIndicatorSection(
                pillTitle: "細部操作",
                rows: [
                    .item(title: "紀錄明細", body: "點進任一消費紀錄後，可以查看金額、分類、時間與地點。"),
                    .item(title: "編輯紀錄", body: "在明細頁可修改日期、金額、小費、人數、分類與地址。"),
                    .item(title: "地點選擇", body: "地圖頁支援手動點選地圖與文字搜尋地點。"),
                    .item(title: "資料分享", body: "分析頁可匯出 PDF，明細頁則可直接分享該筆消費資訊。"),
                    .item(title: "快速刷新", body: "多個主頁面右上角都有刷新按鈕，可重新載入最新資料。")
                ]
            ),
            AppIndicatorSection(
                pillTitle: "使用提醒",
                rows: [
                    .item(title: "定位權限", body: "如果地點無法自動帶入，可到系統設定開啟定位權限。"),
                    .item(title: "觸覺回饋", body: "設定頁可控制點擊互動時是否啟用震動回饋。"),
                    .item(title: "資料管理", body: "消費紀錄頁提供整批刪除，單筆明細頁也可刪除個別資料。")
                ]
            )
        ]
    }
}
