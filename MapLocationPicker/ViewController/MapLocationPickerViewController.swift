//
//  MapLocationPickerViewController.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/5.
//

import Combine
import CoreLocation
import MapKit
import SnapKit
import UIKit

@MainActor
final class MapLocationPickerViewController: BaseViewController {

    var onSelect: ((String, Double, Double) -> Void)?

    private let viewModel: MapLocationPickerViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: MapLocationPickerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    convenience init(initialAddress: String? = nil, latitude: Double? = nil, longitude: Double? = nil) {
        let vm = MapLocationPickerViewModel(initialAddress: initialAddress, latitude: latitude, longitude: longitude)
        self.init(viewModel: vm)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Subviews

    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        map.showsCompass = true
        map.delegate = self
        return map
    }()

    private let searchContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 12
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.15
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 8
        return v
    }()

    private let searchField: UITextField = {
        let field = UITextField()
        field.placeholder = "搜尋地點或店名"
        field.font = .systemFont(ofSize: 16)
        field.returnKeyType = .search
        field.clearButtonMode = .whileEditing
        field.backgroundColor = .clear
        return field
    }()

    private let searchIconImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iv.tintColor = .tertiaryLabel
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let resultsTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.layer.cornerRadius = 12
        table.backgroundColor = .systemBackground
        table.rowHeight = 56
        table.isHidden = true
        return table
    }()

    private let bottomCardView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 16
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.1
        v.layer.shadowOffset = CGSize(width: 0, height: -2)
        v.layer.shadowRadius = 12
        return v
    }()

    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.text = "點擊地圖或搜尋選擇地點"
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    private lazy var confirmButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("確認", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        btn.tintColor = .white
        btn.backgroundColor = ThemeColor.primary
        btn.addCornerRadius(radius: 10)
        btn.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        btn.isEnabled = false
        btn.alpha = 0.5
        return btn
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "選擇地點"
        setupLayout()
        bindViewModel()
        centerOnInitialOrUser()
    }

    // MARK: - Setup

    private func setupLayout() {
        setupMap()
        setupSearchBar()
        setupResultsTable()
        setupBottomCard()
        addMapTapGesture()
    }

    private func setupMap() {
        view.insertSubview(mapView, at: 0)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "SelectedPin")
    }

    private func setupSearchBar() {
        view.addSubview(searchContainerView)
        searchContainerView.addSubview(searchIconImageView)
        searchContainerView.addSubview(searchField)

        searchContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        searchIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        searchField.snp.makeConstraints { make in
            make.leading.equalTo(searchIconImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(searchFieldDidChange), for: .editingChanged)
    }

    private func setupResultsTable() {
        view.addSubview(resultsTableView)
        resultsTableView.snp.makeConstraints { make in
            make.top.equalTo(searchContainerView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(200)
        }
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.register(MapLocationPickerSearchResultCell.self, forCellReuseIdentifier: MapLocationPickerSearchResultCell.reuseId)
    }

    private func setupBottomCard() {
        view.addSubview(bottomCardView)
        bottomCardView.addSubview(addressLabel)
        bottomCardView.addSubview(confirmButton)

        bottomCardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(view.snp.height).multipliedBy(0.20)
        }
        addressLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(confirmButton.snp.top).offset(-12)
        }
        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
    }

    private func addMapTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        mapView.addGestureRecognizer(tap)
    }

    private func bindViewModel() {
        viewModel.$addressDisplayText
            .sink { [weak self] text in self?.addressLabel.text = text }
            .store(in: &cancellables)

        viewModel.$isConfirmEnabled
            .sink { [weak self] enabled in
                self?.confirmButton.isEnabled = enabled
                self?.confirmButton.alpha = enabled ? 1 : 0.5
            }
            .store(in: &cancellables)

        viewModel.$selectedCoordinate
            .sink { [weak self] coord in self?.updatePin(for: coord) }
            .store(in: &cancellables)

        viewModel.$searchResults
            .sink { [weak self] _ in
                self?.resultsTableView.reloadData()
                self?.resultsTableView.isHidden = (self?.viewModel.searchResults.isEmpty ?? true)
            }
            .store(in: &cancellables)
    }

    private func updatePin(for coord: CLLocationCoordinate2D?) {
        mapView.removeAnnotations(mapView.annotations.filter { $0 is SelectedLocationAnnotation })
        if let coord = coord {
            mapView.addAnnotation(SelectedLocationAnnotation(coordinate: coord))
        }
    }

    private func centerOnInitialOrUser() {
        if let lat = viewModel.initialLatitude, let lon = viewModel.initialLongitude {
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            mapView.setRegion(MKCoordinateRegion(center: coord, latitudinalMeters: 500, longitudinalMeters: 500), animated: false)
            return
        }
        if let loc = mapView.userLocation.location {
            let region = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
            mapView.setRegion(region, animated: false)
        } else {
            let taipei = CLLocationCoordinate2D(latitude: 25.0330, longitude: 121.5654)
            mapView.setRegion(MKCoordinateRegion(center: taipei, latitudinalMeters: 5000, longitudinalMeters: 5000), animated: false)
        }
    }

    // MARK: - Actions

    @objc private func searchFieldDidChange() {
        let center = mapView.userLocation.location?.coordinate ?? mapView.region.center
        viewModel.search(query: searchField.text ?? "", regionCenter: center)
    }

    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let center = mapView.userLocation.location?.coordinate ?? mapView.region.center
        viewModel.searchImmediate(query: searchField.text ?? "", regionCenter: center)
        textField.resignFirstResponder()
        return true
    }

    @objc private func mapTapped(_ gesture: UITapGestureRecognizer) {
        resultsTableView.isHidden = true
        searchField.resignFirstResponder()
        let point = gesture.location(in: mapView)
        let coord = mapView.convert(point, toCoordinateFrom: mapView)
        viewModel.selectCoordinate(coord)
    }

    @objc private func confirmTapped() {
        guard let result = viewModel.selectedResult else { return }
        onSelect?(result.address, result.lat, result.lon)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MapLocationPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MapLocationPickerSearchResultCell.reuseId, for: indexPath)
        guard let resultCell = cell as? MapLocationPickerSearchResultCell,
              viewModel.searchResults.indices.contains(indexPath.row) else {
            return cell
        }
        resultCell.configure(with: viewModel.searchResults[indexPath.row])
        return resultCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard viewModel.searchResults.indices.contains(indexPath.row) else { return }
        let item = viewModel.searchResults[indexPath.row]
        resultsTableView.isHidden = true
        searchField.resignFirstResponder()
        viewModel.selectSearchResult(item)
        mapView.setCenter(item.coordinate, animated: true)
    }
}

// MARK: - MKMapViewDelegate

extension MapLocationPickerViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is SelectedLocationAnnotation else { return nil }
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "SelectedPin", for: annotation) as? MKMarkerAnnotationView
        view?.markerTintColor = ThemeColor.primary
        return view
    }
}
