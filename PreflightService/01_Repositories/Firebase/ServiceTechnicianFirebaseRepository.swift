//
//  ServiceTechnicianFirebaseRepository.swift
//  PreflightService
//
//  Created by Florian Rhein on 22.10.24.
//

import FirebaseFirestore
import Foundation

class ServiceTechnicianFirebaseRepository {

    private let firestore = Firestore.firestore()

    // MARK: - CREATE

    // Erzeugt eine:n neue:n Wartungstechniker:in im Firestore auf Grundlage der übergebenen Parameter.
    // Die Parameter werden hier nicht validiert! Wenn die Funktion von einem ViewModel aufgerufen wird, muss das ViewModel die Daten vorher validieren!
    // Anmerkung: Diese Funktion wird noch nicht verwendet. Ggf kann sie im AuthenticationViewModel verwendet werden.
    func createServiceTechnician(userId: String, email: String, name: String, phoneNumber: String, maintenanceLevel: ServiceTechnicianMaintenanceLevel) throws -> ServiceTechnician {
        let newServiceTechnician = ServiceTechnician(
            userId: userId,
            email: email,
            name: name,
            phoneNumber: phoneNumber,
            maintenanceLevel: maintenanceLevel
        )

        try firestore.collection("serviceTechnicians").document(userId).setData(from: newServiceTechnician)
        return newServiceTechnician
    }

    func getAllTechniciansRepository() async throws -> [ServiceTechnician]  {
        let document = try await
        firestore.collection("serviceTechnicians").getDocuments()
        let serviceTechnicians: [ServiceTechnician] = document.documents.compactMap {
            try? $0.data(as: ServiceTechnician.self)
        }
            
       
        return serviceTechnicians
    }
    // MARK: - READ

    // Ruft eine:n Wartungstechniker:in aus dem Firestore ab.
    // Anmerkung: Diese Funktion wird noch nicht verwendet. Ggf kann sie im AuthenticationViewModel verwendet werden.
    func getServiceTechnician(forUserId userId: String) async throws -> ServiceTechnician {
        let document = try await firestore.collection("serviceTechnicians").document(userId).getDocument()
        let serviceTechnician = try document.data(as: ServiceTechnician.self)
        return serviceTechnician
    }
}
