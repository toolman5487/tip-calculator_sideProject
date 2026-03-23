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

    func analyze(filterIndex: Int) {
        guard #available(iOS 26.0, *) else {
            state = .unavailable("此功能需要 iOS 26 或更新版本")
            return
        }

        let options = AccountDetailAnalysisModel.filterOptions
        guard filterIndex >= 0, filterIndex < options.count else { return }

        state = .loading
        let filterOption = options[filterIndex]
        Task {
            await performAnalysis(filterOption: filterOption)
        }
    }

    @available(iOS 26.0, *)
    private func performAnalysis(filterOption: AnalysisFilterOption) async {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            break
        case .unavailable(.deviceNotEligible):
            state = .unavailable("此裝置不支援此功能")
            return
        case .unavailable(.appleIntelligenceNotEnabled):
            state = .unavailable("請在設定中開啟 Apple Intelligence")
            return
        case .unavailable(.modelNotReady):
            state = .unavailable("模型正在準備中，請稍後再試")
            return
        case .unavailable:
            state = .unavailable("目前無法使用，請稍後再試")
            return
        }

        let prompt = AnalysisPromptBuilder.buildPrompt(recordsText: recordsText, filterOption: filterOption)

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
                state = .error("資料過多，請減少紀錄後再試")
            } else {
                state = .error("分析失敗，請稍後再試")
            }
        }
    }
}
