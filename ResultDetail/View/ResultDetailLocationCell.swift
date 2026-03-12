//
//  ResultDetailLocationCell.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/6.
//

import UIKit
import MapKit
import SnapKit

final class ResultDetailLocationCell: ResultDetailTableViewCell {

    static let locationReuseId = "ResultDetailLocationCell"

    private var mapHeightConstraint: Constraint?
    private var currentCoordinate: CLLocationCoordinate2D?
    private var currentAddress: String?

    private let mapView: MKMapView = {
        let map = MKMapView()
        map.isUserInteractionEnabled = true
        map.isScrollEnabled = false
        map.isZoomEnabled = false
        map.layer.cornerRadius = 8
        map.layer.masksToBounds = true
        return map
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLocationViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLocationViews()
    }

    private func setupLocationViews() {
        contentView.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(4)
            make.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            mapHeightConstraint = make.height.equalTo(140).constraint
            make.bottom.equalToSuperview().offset(-10)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        mapView.addGestureRecognizer(tap)
    }

    @objc private func mapTapped() {
        guard let coordinate = currentCoordinate else { return }
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = currentAddress
        let options: [String: Any] = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinate),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)),
            MKLaunchOptionsShowsTrafficKey: true
        ]
        mapItem.openInMaps(launchOptions: options)
    }

    func configure(title: String, value: String, coordinate: CLLocationCoordinate2D?) {
        super.configure(title: title, value: value, systemImageName: "mappin.and.ellipse")

        if let coordinate {
            currentCoordinate = coordinate
            currentAddress = value.isEmpty ? nil : value
            mapView.isHidden = false
            mapHeightConstraint?.update(offset: 140)

            let region = MKCoordinateRegion(center: coordinate,
                                            latitudinalMeters: 800,
                                            longitudinalMeters: 800)
            mapView.setRegion(region, animated: false)

            mapView.removeAnnotations(mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        } else {
            currentCoordinate = nil
            currentAddress = nil
            mapView.isHidden = true
            mapHeightConstraint?.update(offset: 0)
        }
    }
}

