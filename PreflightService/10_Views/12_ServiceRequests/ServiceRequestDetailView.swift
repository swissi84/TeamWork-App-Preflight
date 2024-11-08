//
//  ServiceRequestDetailView.swift
//  PreflightService
//
//  Created by Florian Rhein on 21.10.24.
//

import SwiftUI

struct ServiceRequestDetailView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @StateObject var serviceRequestViewModel: ServiceRequestViewModel
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject var techniciansListViewModel: TechniciansListViewModel
    
    
    @State private var isPresented = false
    @State private var showAvailableTechniciansSheet: Bool = false


    // Initialisert diese View, indem ein ServiceRequestViewModel für den übergebenen Wartungsauftrag erzeugt wird
    init(serviceRequest: ServiceRequest) {
        self._serviceRequestViewModel = .init(wrappedValue: .init(serviceRequest: serviceRequest))
    }

    var body: some View {
        VStack {
            HStack {
                Image(systemName: serviceRequestViewModel.serviceRequestStatus.systemImage)
                Text(serviceRequestViewModel.serviceRequestStatus.displayText)
                    .font(.title3)
                    .bold()
                Spacer()
                Image(systemName: "wrench.and.screwdriver")
                Text(serviceRequestViewModel.serviceRequest.serviceLevel)
                    .font(.title3)
            }
            
            .padding()
            .background(serviceRequestViewModel.serviceRequestStatus.statusBadgeColor)
            VStack{
                ScrollView {
                    Text("Auftragsdaten")
                        .font(.title2)
                    DetailDescriptionField(labelText: "Fällig am", content: serviceRequestViewModel.serviceRequest.dateDue.formatted(date: .abbreviated, time: .omitted))
                    DetailDescriptionField(labelText: "Aufgabenbeschreibung", content: serviceRequestViewModel.serviceRequest.description)
                    
                    Text("Flugzeugdaten")
                        .font(.title2)
                    // Zeigt daten zu dem Flugzeug an, welches zu diesem Wartungsauftrag gehört
                    // Solange die Daten nicht geladen sind, wird ein ProgressView() stattdessen angezigt
                    if let airplane = serviceRequestViewModel.airplane {
                        AsyncImage(
                            url: URL(string: airplane.imgThumb ?? ""),
                            content: { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200)
                                    .cornerRadius(10)
                            },
                            placeholder: {
                                ProgressView()
                            }
                        )
                        
                        DetailDescriptionField(
                            labelText: "Hersteller",
                            content: airplane.brand
                        )
                        DetailDescriptionField(
                            labelText: "Modell",
                            content: serviceRequestViewModel.serviceRequest.airplaneName
                        )
                        DetailDescriptionField(
                            labelText: "Leergewicht",
                            content: "\(airplane.emptyWeightKg!.formatted(.number)) kg"
                        )
                        DetailDescriptionField(
                            labelText: "Max. Startgewicht",
                            content: "\(airplane.maxTakeoffWeightKg!.formatted(.number)) kg"
                        )
                        DetailDescriptionField(
                            labelText: "Max. Landungsgewicht",
                            content: "\(airplane.maxLandingWeightKg!.formatted(.number)) kg"
                        )
                        DetailDescriptionField(
                            labelText: "Triebwerk",
                            content: airplane.engine!
                        )
                        DetailDescriptionField(
                            labelText: "Tank",
                            content: "\(airplane.fuelCapacityLitres!.formatted(.number)) l"
                        )
                    } else {
                        Text("Flugzeugdaten werden geladen...")
                        ProgressView()
                    }
                }
                .padding()
            }
            Spacer()
            
            // Zeugt den "Auftrag annehmen"-Button nur an, wenn dieser Wartungsauftrag von der angemeldete:n Techniker:in angenommen werden kann
            HStack {
                if serviceRequestViewModel.canBeAssigned(to: authenticationViewModel.user) {
                    Button("Auftrag annehmen") {
                        if authenticationViewModel.getServiceLevel() == serviceRequestViewModel.serviceRequest.serviceLevel {
                            serviceRequestViewModel.assignServiceRequest(to: authenticationViewModel.user)
                            
                        } else {
                            isPresented = true
                            print("isPresented")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.vertical)
                }
                
                Button("Auftrag zuweisen") {
                    showAvailableTechniciansSheet = true
                }
                .buttonStyle(.borderedProminent)
                .padding(.vertical)
                
                
                // Zeugt den "Auftrag abschließen"-Button nur an, wenn dieser Wartungsauftrag von der angemeldete:n Techniker:in abgeschlossen werden kann
                if serviceRequestViewModel.canBeCompleted(by: authenticationViewModel.user) {
                    Button("Auftrag abschließen") {
                        serviceRequestViewModel.completeServiceRequest()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        
        .alert("Benötigter Serivce Level: \(serviceRequestViewModel.serviceRequest.serviceLevel)", isPresented: $isPresented) { Button("OK", role: .cancel) {} } message: { Text("Dein Service Level ist zu niedrig für diesen Auftrag. Dein Service Level:      \(authenticationViewModel.getServiceLevel())")
        }
        .sheet(isPresented: $showAvailableTechniciansSheet) {
            AssignRequestSheetView(serviceRequestsViewModel: serviceRequestViewModel)
        }
        .onAppear {
            // Startet den Abruf der Flugzeugdaten
            serviceRequestViewModel.fetchAirplaneData()
            
            
            
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationTitle("Wartungsauftrag")
        
    }
}

#Preview {
    NavigationStack {
        ServiceRequestDetailView(
            serviceRequest: .init(
                airplaneName: "A380-800",
                servicedByUserId: nil,
                description: "Perform a comprehensive inspection and scheduled maintenance on aircraft model , focusing on airframe integrity and avionics systems functionality. Check and replace all hydraulic lines and fluid reservoirs as per manufacturer’s guidelines. Conduct a full engine diagnostic, including compression tests and turbine blade inspections. Verify proper operation of navigation and communication systems, recalibrating sensors where necessary. Additionally, ensure that all safety equipment, including oxygen systems and fire suppression units, are tested and certified for operational readiness.",
                dateCreated: Date(),
                dateDue: Date().addingTimeInterval(3600),
                dateCompleted: nil,
                serviceLevel: "junior"
                
            )
        )
        .environmentObject(AuthenticationViewModel())
    }
}
