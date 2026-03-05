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

    static func makeFromBundle() -> GoogleGeocodingService? {
        let apiKey = (Bundle.main.infoDictionary?["GoogleGeocodingAPIKey"] as? String).flatMap { $0.isEmpty ? nil : $0 }
        return apiKey.map { GoogleGeocodingService(apiKey: $0) }
    }

    func reverseGeocode(latitude: Double, longitude: Double, language: String? = nil, completion: @escaping (String?) -> Void) {
        guard let apiKey = apiKey else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        let lang = language ?? Locale.current.language.languageCode?.identifier ?? "en"
        let key = cacheKey(lat: latitude, lon: longitude, lang: lang)
        if let cached = cache[key] {
            DispatchQueue.main.async { completion(cached) }
            return
        }
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=\(apiKey)&language=\(lang)") else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        session.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            do {
                let decoded = try JSONDecoder().decode(GoogleGeocodingResponse.self, from: data)
                guard decoded.status == "OK",
                      let first = decoded.results?.first,
                      let rawAddr = first.formattedAddress, !rawAddr.isEmpty else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                let addr = Self.shortenedAddress(rawAddr)
                if self.cacheOrder.count >= self.maxCacheSize, let oldKey = self.cacheOrder.first {
                    self.cacheOrder.removeFirst()
                    self.cache.removeValue(forKey: oldKey)
                }
                self.cache[key] = addr
                self.cacheOrder.append(key)
                DispatchQueue.main.async { completion(addr) }
            } catch {
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }

    func reverseGeocode(latitude: Double, longitude: Double, language: String? = nil) async -> String? {
        guard let apiKey = apiKey else { return nil }
        let lang = language ?? Locale.current.language.languageCode?.identifier ?? "en"
        let key = cacheKey(lat: latitude, lon: longitude, lang: lang)
        if let cached = cache[key] { return cached }
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=\(apiKey)&language=\(lang)") else {
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

    private func cacheKey(lat: Double, lon: Double, lang: String = "en") -> String {
        let scale = pow(10.0, Double(cachePrecision))
        let latR = (lat * scale).rounded() / scale
        let lonR = (lon * scale).rounded() / scale
        return "\(latR)_\(lonR)_\(lang)"
    }
}
