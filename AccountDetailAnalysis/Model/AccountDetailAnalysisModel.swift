//
//  AccountDetailAnalysisModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/19.
//

import Foundation

// MARK: - AccountDetailAnalysisModel

enum AccountDetailAnalysisModel {

    static let filterOptions: [AnalysisFilterOption] = [
        .overallSummary,
        .categoryBreakdown,
        .savingsSuggestion,
        .spendingTrend,
        .locationAnalysis,
        .tipsAdvice
    ]

    static var filterOptionTitles: [String] {
        filterOptions.map(\.title)
    }
}

// MARK: - AnalysisFilterOption

struct AnalysisFilterOption {

    let title: String
    let promptFocus: String

    static let overallSummary = AnalysisFilterOption(
        title: "總體摘要",
        promptFocus: "總體消費概況，包含總筆數、總金額、使用天數等"
    )

    static let categoryBreakdown = AnalysisFilterOption(
        title: "類別分布",
        promptFocus: "各消費類別的占比與金額分布"
    )

    static let savingsSuggestion = AnalysisFilterOption(
        title: "節省建議",
        promptFocus: "根據消費習慣提出 2～3 點具體節省建議"
    )

    static let spendingTrend = AnalysisFilterOption(
        title: "消費趨勢",
        promptFocus: "消費時間分布與可能的趨勢觀察"
    )

    static let locationAnalysis = AnalysisFilterOption(
        title: "地點分析",
        promptFocus: "常去地點與消費關聯"
    )

    static let tipsAdvice = AnalysisFilterOption(
        title: "小費建議",
        promptFocus: "小費使用習慣與建議"
    )
}

// MARK: - AnalysisPromptBuilder

struct AnalysisPromptBuilder {

    static let maxRecordLength = 2500
    static let timeoutNanoseconds: UInt64 = 60_000_000_000

    static let instructions = """
        你是消費理財小助手。根據用戶提供的消費紀錄，提供簡潔的分析與建議。
        用繁體中文回應，語氣友善、專業。
        若資料不足，請溫和說明並給予一般性建議。
        """

    static func buildPrompt(recordsText: String, filterOption: AnalysisFilterOption) -> String {
        let truncated = String(recordsText.prefix(maxRecordLength))
        return """
            請針對「\(filterOption.promptFocus)」分析以下消費紀錄。
            回應請簡潔，2～4 段即可。

            消費紀錄（TSV 格式）：
            \(truncated)
            """
    }
}

// MARK: - AccountDetailAnalysisState

enum AccountDetailAnalysisState {
    case idle
    case loading
    case loaded(String)
    case unavailable(String)
    case error(String)
}

// MARK: - AnalysisTimeoutError

struct AnalysisTimeoutError: Error {}
