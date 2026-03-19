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
    case furniture
    case transport
    case drink
    case education
    case gaming
    case movie
    case music
    case exhibition
    case ktv
    case themePark
    case boardGame
    case fmcg
    case gift
    case medical
    case consultation
    case medicine
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
    case metro
    case ferry
    case motorcycle
    case fuel

    // MARK: - Presentation

    static let mainGridCategories: [Category] = [.food, .clothing, .housing, .transport]
    static let sheetCategories: [Category] = allCases.filter { $0 != .none && !mainGridCategories.contains($0) }

    var displayName: String { info.displayName }
    var systemImageName: String? { info.resolvedIcon }
    var sheetSectionTitle: String? { info.sectionTitle }

    // MARK: - Identifier

    var identifier: String { self == .none ? "" : String(describing: self) }

    init?(identifier: String) {
        guard !identifier.isEmpty, let match = Self.identifierMap[identifier] else { return nil }
        self = match
    }

    // MARK: - Private

    private var info: Info { Self.infoTable[self] ?? .unknown }

    private static let infoTable: [Category: Info] = [
        .none: .init("未知", icon: "questionmark"),
        .food: .init("食物", icon: "fork.knife"),
        .clothing: .init("服飾", icon: "tshirt.fill"),
        .housing: .init("居住", icon: "house.fill"),
        .furniture: .init("居家用品", icon: "sofa.fill", section: "家庭"),
        .transport: .init("交通", icon: "figure.walk"),
        .drink: .init("飲料", icon: "cup.and.saucer.fill", section: "飲食"),
        .education: .init("教育", icon: "book.fill", section: "教育"),
        .gaming: .init("電玩", icon: "gamecontroller.fill", section: "娛樂"),
        .movie: .init("電影", icon: "film.fill", section: "娛樂"),
        .music: .init("音樂", icon: "music.note", section: "娛樂"),
        .exhibition: .init("展覽", icon: "photo.artframe", section: "娛樂"),
        .ktv: .init("KTV", icon: "music.mic", section: "娛樂"),
        .themePark: .init("遊樂園", icon: "ticket.fill", section: "娛樂"),
        .boardGame: .init("桌遊", icon: "puzzlepiece.fill", section: "娛樂"),
        .fmcg: .init("民生消費", icon: "bag.fill", section: "日常消費"),
        .gift: .init("禮物", icon: "gift.fill", section: "日常消費"),
        .medical: .init("醫療", icon: "cross.case.fill", section: "健康"),
        .consultation: .init("看診", icon: "stethoscope", section: "健康"),
        .medicine: .init("藥品", icon: "pill.fill", section: "健康"),
        .running: .init("跑步", icon: "figure.run", section: "運動"),
        .swimming: .init("游泳", icon: "figure.pool.swim", section: "運動"),
        .cycling: .init("騎車", icon: "bicycle", section: "運動"),
        .gym: .init("重訓", icon: "dumbbell.fill", section: "運動"),
        .ballSports: .init("球類", icon: "basketball.fill", section: "運動"),
        .child: .init("育兒", icon: "figure.2.and.child.holdinghands", section: "家庭"),
        .pet: .init("寵物", icon: "pawprint.fill", section: "家庭"),
        .taxi: .init("汽車", icon: "car.fill", section: "交通"),
        .bus: .init("巴士", icon: "bus.fill", section: "交通"),
        .train: .init("火車", icon: "train.side.front.car", section: "交通"),
        .airplane: .init("飛機", icon: "airplane", section: "交通"),
        .metro: .init("地鐵/捷運", icon: "tram.fill.tunnel", section: "交通"),
        .ferry: .init("航運", icon: "ferry", section: "交通"),
        .motorcycle: .init("摩托車", icon: "scooter", iconFallback: "scooter", section: "交通"),
        .fuel: .init("加油", icon: "fuelpump.fill", section: "交通"),
    ]

    private static let identifierMap: [String: Category] = Dictionary(
        uniqueKeysWithValues: allCases.compactMap { c in
            c.identifier.isEmpty ? nil : (c.identifier, c)
        }
    )
}

// MARK: - Info

private struct Info {
    let displayName: String
    let icon: String
    let iconFallback: String?
    let sectionTitle: String?

    static let unknown = Info("未知", icon: "questionmark")

    init(_ displayName: String, icon: String, iconFallback: String? = nil, section: String? = nil) {
        self.displayName = displayName
        self.icon = icon
        self.iconFallback = iconFallback
        self.sectionTitle = section
    }

    var resolvedIcon: String? {
        guard let fallback = iconFallback else { return icon }
        if #available(iOS 16.0, *) { return icon }
        return fallback
    }
}
