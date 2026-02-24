//
//  CategoryPickerSheetModel.swift
//  tip-calculator
//

import Foundation

struct CategoryPickerSection {
    let title: String
    let categories: [Category]
}

enum CategoryPickerSheetModel {
    static let sections: [CategoryPickerSection] = {
        var seen: [String: Int] = [:]
        var result: [CategoryPickerSection] = []
        for category in Category.sheetCategories {
            guard let title = category.sheetSectionTitle else { continue }
            if let idx = seen[title] {
                result[idx] = CategoryPickerSection(
                    title: result[idx].title,
                    categories: result[idx].categories + [category]
                )
            } else {
                seen[title] = result.count
                result.append(CategoryPickerSection(title: title, categories: [category]))
            }
        }
        return result.sorted { $0.categories.count < $1.categories.count }
    }()
}
