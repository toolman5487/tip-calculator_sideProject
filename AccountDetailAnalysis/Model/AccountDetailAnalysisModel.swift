//
//  AccountDetailAnalysisModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/19.
//

import Foundation

// MARK: - AccountDetailAnalysisState

enum AccountDetailAnalysisState {
    case idle
    case loading
    case loaded(String)
    case unavailable(String)
    case error(String)
}

// MARK: - AnalysisPromptBuilder

struct AnalysisPromptBuilder {

    static let maxRecordLength = 2500
    static let timeoutNanoseconds: UInt64 = 60_000_000_000

    static let instructions = """
    你是一位個人財務助理，會根據使用者的消費紀錄提供精簡的分析與建議。
    請一律使用「繁體中文」回覆，語氣友善且專業。
    如果資料不足，請溫和說明原因，並提供一般性的理財建議。
    """

    static func buildPrompt(recordsText: String) -> String {
        let truncated = String(recordsText.prefix(maxRecordLength))
        return """
        請分析以下消費紀錄，並以條列方式回覆內容（使用繁體中文）：
        1. 消費概況摘要（約 2–3 句）
        2. 主要消費類別與大致比例
        3. 1–2 點精簡的建議

        消費紀錄（TSV 格式）：
        \(truncated)
        """
    }
}

// MARK: - AnalysisTimeoutError

struct AnalysisTimeoutError: Error {}
