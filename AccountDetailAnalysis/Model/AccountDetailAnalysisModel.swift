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
    你是消費紀錄 App 內建的 AI 助理，專門分析使用者的消費數據。
    請以消費紀錄 App 的視角回覆：聚焦在支出分析、消費習慣、類別分布與實用建議。
    一律使用繁體中文，語氣簡潔友善，總結重點，自動分段。
    若資料不足，請溫和說明並給予一般性的記帳建議。
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
