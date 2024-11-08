//
//  TechniciansListViewModel.swift
//  PreflightService
//
//  Created by mario loesel on 31.10.24.
//

import Foundation
import FirebaseFirestore

@MainActor
class TechniciansListViewModel: ObservableObject {
    
    @Published var allTechnicians: [ServiceTechnician] = []
    
    private let serviceTechnicianFirebasRepository = ServiceTechnicianFirebaseRepository()
    
    
    func fetchAllTechnicians() async {
        do {
            let technicians = try await serviceTechnicianFirebasRepository.getAllTechniciansRepository()
            self.allTechnicians = technicians
            
        }
        catch {
            print("Fehler beim Abrufen der Servicetechniker")
        }
    }
    
}
