//
//  ResultDetailLocationCell.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/6.
//

import UIKit
import MapKit
import SnapKit

final class ResultDetailLocationCell: ResultDeetailTableViewCell {

    static let locationReuseId = "ResultDetailLocationCell"

    private var mapHeightConstraint: Constraint?

    private let mapView: MKMapView = {
        let map = MKMapView()
        map.isUserInteractionEnabled = false
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
    }

    func configure(title: String, value: String, coordinate: CLLocationCoordinate2D?) {
        super.configure(title: title, value: value, systemImageName: "mappin.and.ellipse")

        if let coordinate {
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
            mapView.isHidden = true
            mapHeightConstraint?.update(offset: 0)
        }
    }
}

