//
//  MapLocationPickerViewModel.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/3/5.
//

import Combine
import CoreLocation
import MapKit

@MainActor
final class MapLocationPickerViewModel {

    // MARK: - Output

    @Published private(set) var selectedCoordinate: CLLocationCoordinate2D?
    @Published private(set) var searchResults: [MapLocationPickerSearchResultItem] = []
    @Published private(set) var addressDisplayText: String = "點擊地圖或搜尋選擇地點"
    @Published private(set) var isConfirmEnabled: Bool = false

    private var selectedAddress: String = ""
    let initialAddress: String?
    let initialLatitude: Double?
    let initialLongitude: Double?

    // MARK: - Dependencies

    private let searchService: LocationSearching
    private let reverseGeocodeService: ReverseGeocoding
    private let searchQuerySubject = PassthroughSubject<(String, CLLocationCoordinate2D), Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        initialAddress: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        searchService: LocationSearching = MKLocationSearchService(),
        reverseGeocodeService: ReverseGeocoding = ReverseGeocodeService()
    ) {
        self.initialAddress = initialAddress
        self.initialLatitude = latitude
        self.initialLongitude = longitude
        self.searchService = searchService
        self.reverseGeocodeService = reverseGeocodeService
        setupSearchBinding()
        applyInitialState()
    }

    // MARK: - Input

    func search(query: String, regionCenter: CLLocationCoordinate2D) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            searchResults = []
            return
        }
        searchQuerySubject.send((trimmed, regionCenter))
    }

    func searchImmediate(query: String, regionCenter: CLLocationCoordinate2D) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        performSearch(query: trimmed, center: regionCenter)
    }

    func selectCoordinate(_ coord: CLLocationCoordinate2D, knownAddress: String? = nil) {
        selectedCoordinate = coord
        isConfirmEnabled = true
        if let addr = knownAddress {
            selectedAddress = addr
            addressDisplayText = addr
        } else {
            addressDisplayText = "反查中…"
            reverseGeocodeService.reverseGeocode(latitude: coord.latitude, longitude: coord.longitude) { [weak self] addr in
                self?.handleReverseGeocodeResult(coord: coord, address: addr)
            }
        }
    }

    func selectSearchResult(_ item: MapLocationPickerSearchResultItem) {
        selectCoordinate(item.coordinate, knownAddress: item.displayAddress.isEmpty ? nil : item.displayAddress)
        searchResults = []
    }

    // MARK: - Output Helper

    var selectedResult: (address: String, lat: Double, lon: Double)? {
        guard let coord = selectedCoordinate else { return nil }
        let addr = selectedAddress.isEmpty ? "\(coord.latitude), \(coord.longitude)" : selectedAddress
        return (addr, coord.latitude, coord.longitude)
    }

    // MARK: - Private

    private func setupSearchBinding() {
        searchQuerySubject
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .sink { [weak self] query, center in
                self?.performSearch(query: query, center: center)
            }
            .store(in: &cancellables)
    }

    private func applyInitialState() {
        if let lat = initialLatitude, let lon = initialLongitude {
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            selectedCoordinate = coord
            selectedAddress = initialAddress ?? ""
            addressDisplayText = selectedAddress.isEmpty ? "緯度 \(lat), 經度 \(lon)" : selectedAddress
            isConfirmEnabled = true
        }
    }

    private func performSearch(query: String, center: CLLocationCoordinate2D) {
        searchService.search(query: query, regionCenter: center) { [weak self] mapItems in
            self?.searchResults = mapItems.map { MapLocationPickerSearchResultItem(mkMapItem: $0) }
        }
    }

    private func handleReverseGeocodeResult(coord: CLLocationCoordinate2D, address: String?) {
        if let addr = address, !addr.isEmpty {
            selectedAddress = addr
            addressDisplayText = addr
        } else {
            selectedAddress = ""
            addressDisplayText = "緯度 \(coord.latitude), 經度 \(coord.longitude)"
        }
    }
}
