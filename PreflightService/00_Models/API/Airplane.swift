//
//  Airplane.swift
//  PreflightService
//
//  Created by Florian Rhein on 21.10.24.
//

import Foundation

// Bildet die Antwort von der API "airplanesdb.p.rapidapi.com" ab
struct Airplane: Codable, Identifiable {
    let id: Int
    let plane: String
    let brand: String
    let passengerCapacity: Int?
    let fuelCapacityLitres: Double?
    let maxTakeoffWeightKg: Double?
    let maxLandingWeightKg: Double?
    let emptyWeightKg: Double?
    let rangeKm: Double?
    let lengthFt: Double?
    let wingspanFt: Double?
    let heightFt: Double?
    let engine: String?
    let cruiseSpeedKmph: Double?
    let ceilingFt: Double?
    let imgThumb: String?

    // Die CodingKeys übersetzen die Bezeichnungen der einzelnen Properties in der Antwort von der API auf die Property-Bezeichnungen in unserem Swift-Model.
    // Wir verwenden CodingKeys, weil die Properties in der Antwort der API in der snake_case Notation geschrieben sind,
    // wir in Swift aber die camelCase Notation verwenden sollten
    enum CodingKeys: String, CodingKey {
        case id, plane, brand, engine, imgThumb

        case passengerCapacity = "passenger_capacity"
        case fuelCapacityLitres = "fuel_capacity_litres"
        case maxTakeoffWeightKg = "max_takeoff_weight_kg"
        case maxLandingWeightKg = "max_landing_weight_kg"
        case emptyWeightKg = "empty_weight_kg"
        case rangeKm = "range_km"
        case lengthFt = "length_ft"
        case wingspanFt = "wingspan_ft"
        case heightFt = "height_ft"
        case cruiseSpeedKmph = "cruise_speed_kmph"
        case ceilingFt = "ceiling_ft"
    }
}
