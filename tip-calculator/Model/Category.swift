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
    case drink
    case education
    case entertainment
    case shopping
    case subscription
    case gift
    case insurance
    case medical
    case beauty
    case running
    case swimming
    case cycling
    case gym
    case ballSports
    case child
    case pet
    case taxi
    case bus
    case train
    case airplane

    static let mainGridCategories: [Category] = [.food, .clothing, .housing, .transport]
    static let sheetCategories: [Category] = allCases.filter { $0 != .none && !mainGridCategories.contains($0) }

// MARK: - Info Table
    private struct Info {
        let displayName: String
        let icon: String?
        let sectionTitle: String?
    }

    private static let infoTable: [Category: Info] = [
        .none: .init(displayName: "無", icon: nil, sectionTitle: nil),
        .food: .init(displayName: "飲食", icon: "fork.knife", sectionTitle: nil),
        .clothing: .init(displayName: "服飾", icon: "tshirt.fill", sectionTitle: nil),
        .housing: .init(displayName: "居住", icon: "house.fill", sectionTitle: nil),
        .transport: .init(displayName: "交通", icon: "car.fill", sectionTitle: nil),
        .drink: .init(displayName: "飲料", icon: "cup.and.saucer.fill", sectionTitle: "飲食"),
        .education: .init(displayName: "教育", icon: "book.fill", sectionTitle: "教育"),
        .entertainment: .init(displayName: "娛樂", icon: "gamecontroller.fill", sectionTitle: "娛樂"),
        .shopping: .init(displayName: "購物", icon: "bag.fill", sectionTitle: "日常消費"),
        .subscription: .init(displayName: "訂閱", icon: "creditcard.fill", sectionTitle: "日常消費"),
        .gift: .init(displayName: "禮物", icon: "gift.fill", sectionTitle: "日常消費"),
        .insurance: .init(displayName: "保險", icon: "shield.fill", sectionTitle: "日常消費"),
        .medical: .init(displayName: "醫療", icon: "cross.case.fill", sectionTitle: "健康"),
        .beauty: .init(displayName: "美容", icon: "sparkles", sectionTitle: "健康"),
        .running: .init(displayName: "跑步", icon: "figure.run", sectionTitle: "運動"),
        .swimming: .init(displayName: "游泳", icon: "figure.pool.swim", sectionTitle: "運動"),
        .cycling: .init(displayName: "騎車", icon: "bicycle", sectionTitle: "運動"),
        .gym: .init(displayName: "重訓", icon: "dumbbell.fill", sectionTitle: "運動"),
        .ballSports: .init(displayName: "球類運動", icon: "basketball.fill", sectionTitle: "運動"),
        .child: .init(displayName: "育兒", icon: "figure.2.and.child.holdinghands", sectionTitle: "家庭"),
        .pet: .init(displayName: "寵物", icon: "pawprint.fill", sectionTitle: "家庭"),
        .taxi: .init(displayName: "計程車", icon: "car.fill", sectionTitle: "交通"),
        .bus: .init(displayName: "巴士", icon: "bus.fill", sectionTitle: "交通"),
        .train: .init(displayName: "火車", icon: "tram.fill", sectionTitle: "交通"),
        .airplane: .init(displayName: "飛機", icon: "airplane", sectionTitle: "交通"),
    ]

    var displayName: String        { Self.infoTable[self]!.displayName }
    var systemImageName: String?   { Self.infoTable[self]!.icon }
    var sheetSectionTitle: String? { Self.infoTable[self]!.sectionTitle }

// MARK: - Identifier
    var identifier: String { self == .none ? "" : String(describing: self) }

    private static let identifierMap: [String: Category] = Dictionary(
        uniqueKeysWithValues: allCases.compactMap { c in
            c.identifier.isEmpty ? nil : (c.identifier, c)
        }
    )

    init?(identifier: String) {
        guard !identifier.isEmpty, let match = Self.identifierMap[identifier] else { return nil }
        self = match
    }
}
