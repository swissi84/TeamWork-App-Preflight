//
//  CreateSeriveRequestViewModel.swift
//  PreflightService
//
//  Created by Eggenschwiler Andre on 30.10.24.
//

import Foundation


class CreateServiceRequestViewModel: ObservableObject {
    @Published var airplanes: [Airplane] = []
    @Published var isSearching = false
    
    
    private let airplaneAPIRepository = AirplaneAPIRepository()
    
    func searchAirplanes(withName name: String) {
        isSearching = true
         Task {
             do {
                let resultsAirplane = try await airplaneAPIRepository.getAirplanes(byName: name)
                 
                 self.airplanes = resultsAirplane 
                 
             } catch {
                 print("Fehler bei der Flugzeugsuche: \(error)")
             }
             isSearching = false
         }
     }
 }
