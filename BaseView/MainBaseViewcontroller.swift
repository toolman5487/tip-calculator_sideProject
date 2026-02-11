//
//  MainBaseViewcontroller.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/9.
//

import UIKit
import SnapKit
import Combine

@MainActor
class MainBaseViewController: BaseViewController {

    static let defaultCellReuseId = "Cell"

    private let refreshSubject = PassthroughSubject<Void, Never>()

    var refreshPublisher: AnyPublisher<Void, Never> {
        refreshSubject.eraseToAnyPublisher()
    }

    func triggerRefresh() {
        refreshSubject.send(())
    }

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.sectionHeadersPinToVisibleBounds = true
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.alwaysBounceVertical = true
        cv.bounces = true
        cv.dataSource = self
        cv.delegate = self
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Self.defaultCellReuseId)
        return cv
    }()

    override func setupUI() {
        super.setupUI()
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension MainBaseViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: Self.defaultCellReuseId, for: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MainBaseViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 44)
    }
}
