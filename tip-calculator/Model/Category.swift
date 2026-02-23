//
//  Category.swift
//  tip-calculator
//

import Foundation

enum Category: Int, CaseIterable {
    case none
    case food
    case clothing
    case housing
    case transport
    case education
    case entertainment

    static let mainGridCategories: [Category] = [.food, .clothing, .housing, .transport]
    static var sheetCategories: [Category] {
        allCases.filter { $0 != .none && !mainGridCategories.contains($0) }
    }

    var identifier: String {
        switch self {
        case .none: return ""
        case .food: return "food"
        case .clothing: return "clothing"
        case .housing: return "housing"
        case .transport: return "transport"
        case .education: return "education"
        case .entertainment: return "entertainment"
        }
    }

    var systemImageName: String? {
        switch self {
        case .none: return nil
        case .food: return "fork.knife"
        case .clothing: return "tshirt.fill"
        case .housing: return "house.fill"
        case .transport: return "car.fill"
        case .education: return "book.fill"
        case .entertainment: return "gamecontroller.fill"
        }
    }

    var displayName: String {
        switch self {
        case .none: return "無"
        case .food: return "食"
        case .clothing: return "衣"
        case .housing: return "住"
        case .transport: return "行"
        case .education: return "育"
        case .entertainment: return "樂"
        }
    }

    init?(identifier: String) {
        guard !identifier.isEmpty,
              let match = Self.allCases.first(where: { $0.identifier == identifier })
        else { return nil }
        self = match
    }
}
