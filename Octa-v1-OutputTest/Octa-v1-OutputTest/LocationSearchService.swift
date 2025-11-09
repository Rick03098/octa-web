import Foundation
#if canImport(CoreLocation)
import CoreLocation
#endif

struct ResolvedLocation: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let longitude: Double
    let latitude: Double
    let timeZoneIdentifier: String

    var timeZone: TimeZone? {
        TimeZone(identifier: timeZoneIdentifier)
    }

    static func == (lhs: ResolvedLocation, rhs: ResolvedLocation) -> Bool {
        lhs.id == rhs.id
    }
}

final class LocationSearchService {
    private let accessToken: String
    private let session: URLSession
#if canImport(CoreLocation)
    private let geocoder = CLGeocoder()
#endif

    init(accessToken: String, session: URLSession = .shared) {
        self.accessToken = accessToken
        self.session = session
    }

    func search(
        query: String,
        limit: Int = 5,
        language: String? = nil,
        types: String = "place,region"
    ) async throws -> [ResolvedLocation] {
        guard !accessToken.isEmpty else {
            throw LocationError.missingAccessToken
        }

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }

        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.mapbox.com"
        let rawPath = "/geocoding/v5/mapbox.places/\(trimmedQuery).json"
        var allowedPathCharacters = CharacterSet.urlPathAllowed
        allowedPathCharacters.remove(charactersIn: "?")
        guard let encodedPath = rawPath.addingPercentEncoding(withAllowedCharacters: allowedPathCharacters) else {
            throw LocationError.invalidQueryEncoding
        }
        components.percentEncodedPath = encodedPath
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "access_token", value: accessToken),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "types", value: types),
            URLQueryItem(name: "timezone", value: "true")
        ]
        if let language, !language.isEmpty {
            queryItems.append(URLQueryItem(name: "language", value: language))
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw LocationError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
#if DEBUG
        print("[Mapbox] URL:", url.absoluteString)
        if let http = response as? HTTPURLResponse {
            print("[Mapbox] Status:", http.statusCode)
        }
        if let bodyString = String(data: data, encoding: .utf8) {
            print("[Mapbox] Body:", bodyString)
        }
#endif

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LocationError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            if let apiError = try? JSONDecoder().decode(MapboxErrorResponse.self, from: data),
               let message = apiError.message {
                throw LocationError.apiError(message)
            }
#if DEBUG
            print("[Mapbox] Non-200 status:", httpResponse.statusCode)
#endif
            throw LocationError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(MapboxGeocodingResponse.self, from: data)
        var locations: [ResolvedLocation] = []

        let sortedFeatures = decoded.features.sorted {
            ($0.relevance ?? 0) > ($1.relevance ?? 0)
        }
        for feature in sortedFeatures {
            guard feature.center.count >= 2 else { continue }
            let longitude = feature.center[0]
            let latitude = feature.center[1]
            let tzFromResponse = feature.properties?.timezone ??
                feature.context?.first(where: { $0.id.hasPrefix("timezone") })?.text

            if let resolvedTZ = await resolveTimezone(longitude: longitude, latitude: latitude, fallback: tzFromResponse) {
                let location = ResolvedLocation(
                    name: feature.placeName,
                    longitude: longitude,
                    latitude: latitude,
                    timeZoneIdentifier: resolvedTZ
                )
                locations.append(location)
            }
        }

        return locations
    }

    private func resolveTimezone(longitude: Double, latitude: Double, fallback: String?) async -> String? {
        if let fallback = fallback { return fallback }
#if canImport(CoreLocation)
        if #available(iOS 15.0, *) {
            let location = CLLocation(latitude: latitude, longitude: longitude)
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                if let tz = placemarks.first?.timeZone?.identifier {
                    return tz
                }
            } catch {
#if DEBUG
                print("[Geocoder] Failed to resolve timezone:", error)
#endif
            }
        }
#endif
        return nil
    }
}

enum LocationError: LocalizedError {
    case missingAccessToken
    case invalidURL
    case invalidResponse
    case invalidQueryEncoding
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .missingAccessToken:
            return "缺少 Mapbox Access Token。"
        case .invalidURL:
            return "无法构建地理编码请求。"
        case .invalidResponse:
            return "未能获取有效的地点信息。"
        case .invalidQueryEncoding:
            return "无法编码地点查询。"
        case .apiError(let message):
            return "Mapbox 返回错误：\(message)"
        }
    }
}

private struct MapboxGeocodingResponse: Decodable {
    let features: [Feature]

    struct Feature: Decodable {
        let id: String
        let placeName: String
        let center: [Double]
        let context: [Context]?
        let properties: Properties?
        let relevance: Double?

        enum CodingKeys: String, CodingKey {
            case id
            case placeName = "place_name"
            case center
            case context
            case properties
            case relevance
        }
    }

    struct Context: Decodable {
        let id: String
        let text: String
    }

    struct Properties: Decodable {
        let timezone: String?
    }
}

private struct MapboxErrorResponse: Decodable {
    let message: String?
}
