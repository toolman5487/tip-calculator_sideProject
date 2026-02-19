//
//  ChartDetailModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/19.
//

import Foundation

enum ChartDetailCategoryOption: Int, CaseIterable {
    case all
    case food
    case clothing
    case housing
    case transport
    case education
    case entertainment

    var displayTitle: String {
        switch self {
        case .all: return "全部"
        case .food: return "食"
        case .clothing: return "衣"
        case .housing: return "住"
        case .transport: return "行"
        case .education: return "育"
        case .entertainment: return "樂"
        }
    }

    var systemImageName: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .food: return "fork.knife"
        case .clothing: return "tshirt.fill"
        case .housing: return "house.fill"
        case .transport: return "car.fill"
        case .education: return "book.fill"
        case .entertainment: return "gamecontroller.fill"
        }
    }
}
