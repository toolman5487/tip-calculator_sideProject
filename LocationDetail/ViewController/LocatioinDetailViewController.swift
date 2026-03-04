//
//  LocatioinDetailViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/3.
//

import Combine
import MapKit
import SnapKit
import UIKit

@MainActor
final class LocationDetailViewController: UIViewController {

    private let viewModel: LocationDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.showsCompass = true
        map.showsScale = true
        map.showsTraffic = true
        map.showsBuildings = true
        map.showsUserLocation = true
        map.delegate = self
        return map
    }()

    private let emptyStateView: EmptyStateView = {
        let v = EmptyStateView()
        v.label.text = "尚無含座標的地區紀錄"
        v.isHidden = true
        return v
    }()

    init(title: String, timeFilter: IllustrationTimeFilterOption) {
        self.viewModel = LocationDetailViewModel(timeFilter: timeFilter)
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
        view.addSubview(mapView)
        view.addSubview(emptyStateView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        emptyStateView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }

    private func bindViewModel() {
        viewModel.$annotations
            .sink { [weak self] annotations in
                guard let self else { return }
                updateAnnotations(annotations)
                let isEmpty = annotations.isEmpty
                emptyStateView.isHidden = !isEmpty
                isEmpty ? emptyStateView.play() : emptyStateView.stop()
            }
            .store(in: &cancellables)

        viewModel.$region
            .compactMap { $0 }
            .sink { [weak self] rect in
                self?.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
            }
            .store(in: &cancellables)
    }

    private func updateAnnotations(_ annotations: [LocationMapAnnotation]) {
        mapView.removeAnnotations(mapView.annotations.filter { $0 is LocationMapAnnotation })
        mapView.addAnnotations(annotations)
    }

    private func presentRecordsSheet(for annotation: LocationMapAnnotation) {
        let items = annotation.records.map { RecordDisplayItem.from($0, dateFormatter: AppDateFormatters.detail) }
        let sheetViewModel = LocationRecordsSheetViewModel(locationTitle: annotation.title ?? "消費紀錄", items: items)
        let listVC = LocationRecordsSheetViewController(viewModel: sheetViewModel)
        let nav = UINavigationController(rootViewController: listVC)
        nav.modalPresentationStyle = .pageSheet
        nav.modalTransitionStyle = .coverVertical
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }
}

// MARK: - MKMapViewDelegate

extension LocationDetailViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let pin = view.annotation as? LocationMapAnnotation else { return }
        presentRecordsSheet(for: pin)
        mapView.deselectAnnotation(pin, animated: false)
    }
}
