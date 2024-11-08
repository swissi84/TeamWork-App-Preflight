//
//  ServiceTechnicianMaintenanceLevel.swift
//  PreflightService
//
//  Created by Florian Rhein on 21.10.24.
//

import Foundation

enum ServiceTechnicianMaintenanceLevel: String, Codable, CaseIterable, Identifiable {
    case junior = "Junior" // Beschreibt eine:n Techniker:in, die sich noch in der Einarbeitung befindet
    case advanced = "Fortgeschritten" // Beschreibt eine:n Techniker:in mit fortgeschrittenen Kenntnissen
    case senior = "Senior"  // Beschreibt eine:n Techniker:in mit besonders umfangreichen Kenntnissen
    
    var id: Self { self }
}
