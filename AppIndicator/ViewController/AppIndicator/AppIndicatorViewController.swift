//
//  AppIndicatorViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/16.
//

import Combine
import UIKit

@MainActor
final class AppIndicatorViewController: MainBaseViewController {

    // MARK: - View Model

    private let viewModel = AppIndicatorViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionView()
        bind()
        collectionView.reloadData()
    }

    // MARK: - Setup

    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "關於 App"
    }

    override func setupUI() {
        super.setupUI()
        view.backgroundColor = .systemGroupedBackground
        collectionView.backgroundColor = .clear
    }

    private func setupCollectionView() {
        collectionView.register(
            AppIndicatorHeroHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: AppIndicatorHeroHeaderView.reuseId
        )
        collectionView.register(
            AppIndicatorFilterHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: AppIndicatorFilterHeaderView.reuseId
        )
        collectionView.register(AppIndicatorItemCell.self, forCellWithReuseIdentifier: AppIndicatorItemCell.reuseId)
    }

    private func bind() {
        viewModel.$selectedSectionIndex
            .dropFirst()
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func presentIntroSheet() {
        let content = AppIndicatorIntroSheetViewController(headerTitle: viewModel.heroHeaderTitle, introText: viewModel.heroHeaderIntro)
        let nav = UINavigationController(rootViewController: content)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension AppIndicatorViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems(in: section)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: AppIndicatorHeroHeaderView.reuseId,
                for: indexPath
            )
        }
        if viewModel.isHeroSection(indexPath.section) {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: AppIndicatorHeroHeaderView.reuseId,
                for: indexPath
            ) as! AppIndicatorHeroHeaderView
            header.configure(title: viewModel.heroHeaderTitle, intro: viewModel.heroHeaderIntro, onTap: { [weak self] in
                self?.presentIntroSheet()
            })
            return header
        }
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: AppIndicatorFilterHeaderView.reuseId,
            for: indexPath
        ) as! AppIndicatorFilterHeaderView
        header.configure(with: viewModel.filterHeaderViewModel)
        return header
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard viewModel.isContentSection(indexPath.section), let row = viewModel.row(at: indexPath.item),
              case .item(let title, let body) = row else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: AppIndicatorItemCell.reuseId, for: indexPath)
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppIndicatorItemCell.reuseId, for: indexPath) as! AppIndicatorItemCell
        cell.configure(title: title, body: body)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AppIndicatorViewController {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = max(0, collectionView.bounds.width - 32)
        guard viewModel.isContentSection(indexPath.section), let row = viewModel.row(at: indexPath.item),
              case .item(let title, let body) = row else { return CGSize(width: width, height: 44) }
        let titleHeight = title.boundingRect(
            with: CGSize(width: width - 8, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: ThemeFont.demiBold(Ofsize: 16)],
            context: nil
        ).height.rounded(.up)
        let bodyHeight = body.boundingRect(
            with: CGSize(width: width - 8, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: ThemeFont.regular(Ofsize: 16)],
            context: nil
        ).height.rounded(.up)
        return CGSize(width: width, height: 14 + titleHeight + 8 + bodyHeight + 14)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.bounds.width
        switch section {
        case AppIndicatorViewModel.heroSectionIndex:
            return CGSize(width: width, height: 160)
        case AppIndicatorViewModel.contentSectionIndex:
            return CGSize(width: width, height: 56)
        default:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case AppIndicatorViewModel.heroSectionIndex: return .zero
        case AppIndicatorViewModel.contentSectionIndex: return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        default: return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        section == AppIndicatorViewModel.contentSectionIndex ? 8 : 0
    }
}

