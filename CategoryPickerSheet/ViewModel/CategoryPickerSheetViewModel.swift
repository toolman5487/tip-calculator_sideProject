//
//  CategoryPickerSheetViewModel.swift
//  tip-calculator
//

import Foundation
import Combine

@MainActor
final class CategoryPickerSheetViewModel {

    let categories: [Category] = Category.sheetCategories
    let currentCategory: Category

    private let selectSubject = PassthroughSubject<Category, Never>()
    var selectPublisher: AnyPublisher<Category, Never> { selectSubject.eraseToAnyPublisher() }

    init(currentCategory: Category) {
        self.currentCategory = currentCategory
    }

    func category(at index: Int) -> Category? {
        guard index >= 0, index < categories.count else { return nil }
        return categories[index]
    }

    func isSelected(at index: Int) -> Bool {
        guard let category = category(at: index) else { return false }
        return category == currentCategory
    }

    func select(at index: Int) {
        guard let category = category(at: index) else { return }
        selectSubject.send(category)
    }
}
