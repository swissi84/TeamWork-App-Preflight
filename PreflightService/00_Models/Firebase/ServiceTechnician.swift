//
//  ServiceTechnician.swift
//  PreflightService
//
//  Created by Florian Rhein on 21.10.24.
//

import Foundation
import Firebase
import FirebaseFirestore

// Bildet eine:n Servicetechniker:in ab, wie sie in FirebaseFirestore gespeichert werden.
struct ServiceTechnician: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    let userId: String // Die Benutzer-ID aus FirebaseAuth, zu der diese:r Servicetechniker:in gehört
    let email: String // Email-Adresse (die gleiche, die zur Anmeldung verwendet wird)
    let name: String // Name des/der Techniker:in
    let phoneNumber: String // Dienstliche Telefonnummer des/der Techniker:in
    let maintenanceLevel: ServiceTechnicianMaintenanceLevel // Das Qualifikations-Level des/der Techniker:in
    var isLeadingTechnician: Bool = false
}
