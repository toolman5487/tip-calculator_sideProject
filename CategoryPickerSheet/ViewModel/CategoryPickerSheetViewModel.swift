//
//  CategoryPickerSheetViewModel.swift
//  tip-calculator
//

import Foundation

@MainActor
final class CategoryPickerSheetViewModel {

    let sections: [CategoryPickerSection] = CategoryPickerSheetModel.sections
    let currentCategory: Category

    var onSelect: ((Category) -> Void)?

    init(currentCategory: Category) {
        self.currentCategory = currentCategory
    }

    func section(at index: Int) -> CategoryPickerSection? {
        guard index >= 0, index < sections.count else { return nil }
        return sections[index]
    }

    func select(category: Category) {
        onSelect?(category)
    }
}
