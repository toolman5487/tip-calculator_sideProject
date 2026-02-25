//
//  ConsumptionBreakdownModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/19.
//

import Foundation

struct PieChartSliceItem {
    let label: String
    let value: Double
}

struct ConsumptionBreakdownCategoryRowItem {
    let label: String
    let value: Double
    let percent: Double
    let iconName: String?
}

enum ConsumptionBreakdownCategoryOption: Int, CaseIterable {
    case all
    case food
    case clothing
    case housing
    case transport
    case drink
    case education
    case gaming
    case fitness
    case child
    case pet
    case gift
    case insurance

    var displayTitle: String {
        guard let id = identifier else { return "全部" }
        return Category(identifier: id)?.displayName ?? "全部"
    }

    var systemImageName: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .food: return "fork.knife"
        case .clothing: return "tshirt.fill"
        case .housing: return "house.fill"
        case .transport: return "car.fill"
        case .drink: return "cup.and.saucer.fill"
        case .education: return "book.fill"
        case .gaming: return "gamecontroller.fill"
        case .fitness: return "figure.run"
        case .child: return "figure.2.and.child.holdinghands"
        case .pet: return "paw.print.fill"
        case .gift: return "gift.fill"
        case .insurance: return "shield.fill"
        }
    }

    var identifier: String? {
        switch self {
        case .all: return nil
        case .food: return "food"
        case .clothing: return "clothing"
        case .housing: return "housing"
        case .transport: return "transport"
        case .drink: return "drink"
        case .education: return "education"
        case .gaming: return "gaming"
        case .fitness: return "fitness"
        case .child: return "child"
        case .pet: return "pet"
        case .gift: return "gift"
        case .insurance: return "insurance"
        }
    }
}
