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
        你是消費理財小助手。根據用戶提供的消費紀錄，提供簡潔的分析與建議。
        用繁體中文回應，語氣友善、專業。
        若資料不足，請溫和說明並給予一般性建議。
        """

    static func buildPrompt(recordsText: String) -> String {
        let truncated = String(recordsText.prefix(maxRecordLength))
        return """
            請分析以下消費紀錄，並提供：
            1. 消費概況摘要（2～3 句）
            2. 主要消費類別與比例
            3. 1～2 點簡短建議

            消費紀錄（TSV 格式）：
            \(truncated)
            """
    }
}

// MARK: - AnalysisTimeoutError

struct AnalysisTimeoutError: Error {}
