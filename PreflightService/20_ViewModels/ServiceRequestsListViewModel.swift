//
//  ServiceRequestsListViewModel.swift
//  PreflightService
//
//  Created by Florian Rhein on 21.10.24.
//

import FirebaseFirestore
import Foundation

// Dieses ViewModel bereitet Daten für das Anzeigen von mehreren Wartungsaufträge in einer Liste auf.
class ServiceRequestsListViewModel: ObservableObject {
    @Published private(set) var openServiceRequests: [ServiceRequest] = []
    @Published private(set) var serviceRequestsForCurrentTechnician: [ServiceRequest] = []
    @Published var serviceRequests: [ServiceRequest] = []
    
    @Published var showAlert = false
   
    private let repository = ServiceRequestsFirebaseRepository()

  
    
    
    // Erzeugt einen Wartungsauftrag mit den übergebenen Parametern.
    func createServiceRequest(airplaneName: String, description: String, dateDue: Date, serviceLevel: String) {
        do {
            try repository.createNewServiceRequest(airplaneName: airplaneName, description: description, dateDue: dateDue, serviceLevel: serviceLevel)
        } catch {
            // TODO: Error handling...
        }
    }

    // Ruft Wartungsaufträge ab, die momentan nicht bearbeitet werden.
    func fetchOpenServiceRequests() {
        repository.startServiceRequestsListenerForOpenRequests { [weak self] serviceRequests in // Hinweis: [weak self] wird hier verwendet, weil das Repository eine @escaping-Closure übergeben bekommt. Mit [weak self] wird in diesem Fall ein Memory Leak verhindert.
            self?.openServiceRequests = serviceRequests
        }
    }

    // Ruft Wartungsaufträge ab, die von der übergenenen Techniker:in bearbeitet werden.
    func fetchServiceRequets(for serviceTechnician: ServiceTechnician?) async {
        guard let serviceTechnician else { return }

        repository.startServiceRequestsListenerForTechnician(serviceTechnician) { [weak self] serviceRequests in // Hinweis: [weak self] wird hier verwendet, weil das Repository eine @escaping-Closure übergeben bekommt. Mit [weak self] wird in diesem Fall ein Memory Leak verhindert.
            self?.serviceRequestsForCurrentTechnician = serviceRequests
            print(serviceRequests)
        }
    }
}


