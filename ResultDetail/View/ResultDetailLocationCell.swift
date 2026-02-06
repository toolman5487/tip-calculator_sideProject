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
            make.height.equalTo(140)
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    func configure(title: String, value: String, coordinate: CLLocationCoordinate2D?) {
        super.configure(title: title, value: value, systemImageName: "mappin.and.ellipse")

        let center: CLLocationCoordinate2D
        if let coordinate {
            center = coordinate
        } else {
            center = CLLocationCoordinate2D(latitude: 25.0330, longitude: 121.5654)
        }

        let region = MKCoordinateRegion(center: center,
                                        latitudinalMeters: 800,
                                        longitudinalMeters: 800)
        mapView.setRegion(region, animated: false)

        mapView.removeAnnotations(mapView.annotations)
        if let coordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
}

