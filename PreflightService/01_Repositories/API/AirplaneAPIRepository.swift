//
//  File.swift
//  PreflightService
//
//  Created by Florian Rhein on 21.10.24.
//

import Foundation

// Ruft Daten zu bestimmten Flugzeugtypen von der API "https://airplanesdb.p.rapidapi.com/" ab
class AirplaneAPIRepository {
    private static let baseUrl: String = "https://airplanesdb.p.rapidapi.com/"

    // Gibt ein bestimmtes Flugzeug für eine ID zurück
    func getAirplane(byId id: Int) async throws -> Airplane {
        var urlRequest = try self.getBaseUrlRequest()
        urlRequest.url?.append(queryItems: [
            .init(name: "id", value: "\(id)")
        ])

        let data = try await self.handleDataResponse(forRequest: urlRequest)

        let results = try JSONDecoder().decode([Airplane].self, from: data)

        guard let firstResult = results.first else {
            throw APIError.dataNotFound
        }

        return firstResult
    }

    // Gibt alle Flugzeuge zurück, die zu einem Namen passen
    func getAirplanes(byName name: String) async throws -> [Airplane] {
        var urlRequest = try self.getBaseUrlRequest()
        urlRequest.url?.append(queryItems: [
            .init(name: "search", value: name)
        ])

        let data = try await self.handleDataResponse(forRequest: urlRequest)

        return try JSONDecoder().decode([Airplane].self, from: data)
    }

    // Erzeugt einen Basis-URL-Request, der für alle Abfragen genutzt werden kann
    // Alle Anfragen richten sich an den Endpunkt "https://airplanesdb.p.rapidapi.com" und benötigen einen API-Key
    private func getBaseUrlRequest() throws -> URLRequest {
        guard let url = URL(string: "https://airplanesdb.p.rapidapi.com/") else {
            throw APIError.invalidUrl
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = [
            "x-rapidapi-key": APIKey.airplaneDb,
            "x-rapidapi-host": "airplanesdb.p.rapidapi.com"
        ]

        return urlRequest
    }

    // Sendet eine Anfrage ab und prüft das Ergebnis.
    // Kann folgende Fehler zurückgeben:
    // - APIError.invalidResponse: wenn keine Antwort erhalten wurde, oder die Antwort nicht dem HTTP-Statuscode 200 ("OK") entspricht
    // - APIError.dataNotFound: wenn zwar eine Antwort erhalten wurde, diese aber keine Daten enthält
    private func handleDataResponse(forRequest request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        guard data.count > 0 else {
            throw APIError.dataNotFound
        }

        return data
    }
}
