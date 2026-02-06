//
//  GoogleGeocodingService.swift
//  tip-calculator
//
//  Created by Willy Hsu on 2026/2/5.
//

import Foundation

struct GoogleGeocodingResponse: Decodable {
    let results: [GoogleGeocodingResult]?
    let status: String?
}

struct GoogleGeocodingResult: Decodable {
    let formattedAddress: String?

    enum CodingKeys: String, CodingKey {
        case formattedAddress = "formatted_address"
    }
}

final class GoogleGeocodingService {

    private let apiKey: String?
    private var cache: [String: String] = [:]
    private var cacheOrder: [String] = []
    private let cachePrecision = 4
    private let maxCacheSize = 50
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 15
        return URLSession(configuration: config)
    }()

    init(apiKey: String? = nil) {
        self.apiKey = apiKey?.isEmpty == true ? nil : apiKey
    }

    func reverseGeocode(latitude: Double, longitude: Double) async -> String? {
        guard let apiKey = apiKey else { return nil }
        let key = cacheKey(lat: latitude, lon: longitude)
        if let cached = cache[key] { return cached }
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=\(apiKey)&language=zh-TW") else {
            return nil
        }
        do {
            let (data, _) = try await session.data(from: url)
            let decoded = try JSONDecoder().decode(GoogleGeocodingResponse.self, from: data)
            if decoded.status != "OK" { return nil }
            guard let first = decoded.results?.first,
                  let rawAddr = first.formattedAddress, !rawAddr.isEmpty else {
                return nil
            }
            let addr = Self.shortenedAddress(rawAddr)
            if cacheOrder.count >= maxCacheSize, let oldKey = cacheOrder.first {
                cacheOrder.removeFirst()
                cache.removeValue(forKey: oldKey)
            }
            cache[key] = addr
            cacheOrder.append(key)
            return addr
        } catch {
            return nil
        }
    }

    private static func shortenedAddress(_ address: String) -> String {
        let withoutNumber = address.replacingOccurrences(
            of: #"\d+號$"#,
            with: "",
            options: .regularExpression
        )
        return withoutNumber.trimmingCharacters(in: .whitespaces)
    }

    private func cacheKey(lat: Double, lon: Double) -> String {
        let scale = pow(10.0, Double(cachePrecision))
        let latR = (lat * scale).rounded() / scale
        let lonR = (lon * scale).rounded() / scale
        return "\(latR)_\(lonR)"
    }
}
