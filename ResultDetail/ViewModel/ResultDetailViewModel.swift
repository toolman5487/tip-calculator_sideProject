//
//  ResultDetailViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/10.
//

import Foundation

enum ResultDetailMode {
    case editable
    case readOnly
}

enum ResultDetailRow {
    case value(title: String, value: String, icon: String)
    case category(title: String, imageName: String)
    case location(title: String, value: String, latitude: Double?, longitude: Double?)
}

@MainActor
final class ResultDetailViewModel {

    private let store: ConsumptionRecordStoring
    private let item: RecordDisplayItem
    let mode: ResultDetailMode

    init(item: RecordDisplayItem, mode: ResultDetailMode = .editable, store: ConsumptionRecordStoring = ConsumptionRecordStore()) {
        self.item = item
        self.mode = mode
        self.store = store
    }

    var headerAmountText: String {
        item.amountPerPersonText
    }

    var shareText: String {
        var lines = [
            "消費明細",
            "每人應付金額：\(item.amountPerPersonText)",
            "時間：\(item.dateText)",
            "總金額：\(item.totalBillText)",
            "帳單金額：\(item.billText)",
            "小費：\(item.totalTipText)",
            "分攤人數：\(item.splitText)",
            "小費設定：\(item.tipDisplayText)"
        ]
        if item.categoryDisplayText != "—" {
            lines.append("消費種類：\(item.categoryDisplayText)")
        }
        if !item.addressText.isEmpty {
            lines.append("消費地點：\(item.addressText)")
        }
        return lines.joined(separator: "\n")
    }

    var rows: [ResultDetailRow] {
        var result: [ResultDetailRow] = [
            .value(title: "時間", value: item.dateText, icon: "clock"),
            .value(title: "總金額", value: item.totalBillText, icon: "dollarsign.circle.fill"),
            .value(title: "帳單金額", value: item.billText, icon: "doc.text.fill"),
            .value(title: "小費", value: item.totalTipText, icon: "percent"),
            .value(title: "分攤人數", value: item.splitText, icon: "person.3.fill"),
            .value(title: "小費設定", value: item.tipDisplayText, icon: "slider.horizontal.3")
        ]
        if item.categoryDisplayText != "—" {
            let imageName = Category.allCases.first { $0.displayName == item.categoryDisplayText }?.systemImageName
                ?? Category.none.systemImageName ?? "questionmark.circle"
            result.append(.category(title: "消費種類", imageName: imageName))
        }
        if !(item.addressText.isEmpty && item.latitude == nil && item.longitude == nil) {
            let value = item.addressText.isEmpty ? "未紀錄" : item.addressText
            result.append(.location(title: "消費地點", value: value, latitude: item.latitude, longitude: item.longitude))
        }
        return result
    }

    var canDelete: Bool {
        item.id != nil
    }

    func deleteRecord() {
        guard let id = item.id else { return }
        store.delete(id: id)
    }
}
