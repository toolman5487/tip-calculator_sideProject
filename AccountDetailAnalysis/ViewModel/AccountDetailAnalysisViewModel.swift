//
//  AccountDetailAnalysisViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/19.
//

import Combine
import Foundation
import FoundationModels

// MARK: - AccountDetailAnalysisViewModel

@MainActor
final class AccountDetailAnalysisViewModel {

    @Published private(set) var state: AccountDetailAnalysisState = .idle

    private let recordsText: String

    init(recordsText: String) {
        self.recordsText = recordsText
    }

    func startAnalysis() {
        if case .loading = state { return }

        guard #available(iOS 26.0, *) else {
            state = .unavailable("此功能需要 iOS 26 或更新版本")
            return
        }

        state = .loading
        Task {
            await performAnalysis()
        }
    }

    @available(iOS 26.0, *)
    private func performAnalysis() async {
        let readiness = await waitForModelReadiness()
        switch readiness {
        case .ready:
            break
        case .deviceNotEligible:
            state = .unavailable("此裝置不支援裝置端 AI 分析")
            return
        case .appleIntelligenceNotEnabled:
            state = .unavailable("請至「設定」中啟用 Apple Intelligence")
            return
        case .modelNotReady:
            state = .unavailable("裝置端模型尚在準備中，請確認已啟用 Apple Intelligence，保持裝置閒置一段時間或重新開機後再試")
            return
        case .unavailable:
            state = .unavailable("裝置端 AI 暫時無法使用，請稍後再試")
            return
        }

        let prompt = AnalysisPromptBuilder.buildPrompt(recordsText: recordsText)

        do {
            let responseText = try await withThrowingTaskGroup(of: String.self) { group in
                group.addTask {
                    let session = LanguageModelSession(instructions: AnalysisPromptBuilder.instructions)
                    let response = try await session.respond(to: Prompt(prompt))
                    return response.content
                }
                group.addTask {
                    try await Task.sleep(nanoseconds: AnalysisPromptBuilder.timeoutNanoseconds)
                    throw AnalysisTimeoutError()
                }
                let result = try await group.next()!
                group.cancelAll()
                return result
            }
            state = .loaded(responseText)
        } catch is AnalysisTimeoutError {
            state = .error("分析逾時（超過 60 秒），請稍後再試")
        } catch {
            if String(describing: error).contains("exceededContextWindowSize") {
                state = .error("資料量過大，請減少消費紀錄後再試")
            } else {
                state = .error("分析失敗，請稍後再試")
            }
        }
    }

    @available(iOS 26.0, *)
    private enum ModelReadinessStatus {
        case ready
        case deviceNotEligible
        case appleIntelligenceNotEnabled
        case modelNotReady
        case unavailable
    }

    @available(iOS 26.0, *)
    private func waitForModelReadiness() async -> ModelReadinessStatus {
        for attempt in 0..<6 {
            let availability = SystemLanguageModel.default.availability

            switch availability {
            case .available:
                return .ready
            case .unavailable(.deviceNotEligible):
                return .deviceNotEligible
            case .unavailable(.appleIntelligenceNotEnabled):
                return .appleIntelligenceNotEnabled
            case .unavailable(.modelNotReady):
                if attempt < 5 {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    continue
                } else {
                    return .modelNotReady
                }
            case .unavailable:
                return .unavailable
            }
        }

        return .modelNotReady
    }
}
