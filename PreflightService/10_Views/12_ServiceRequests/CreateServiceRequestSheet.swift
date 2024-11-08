//
//  CreateServiceRequestView.swift
//  PreflightService
//
//  Created by Eggenschwiler Andre on 30.10.24.
//

import SwiftUI

struct CreateServiceRequestSheet: View {
    @StateObject var createServiceRequestViewModel = CreateServiceRequestViewModel()
    
    @ObservedObject var serviceRequestsViewModel : ServiceRequestsListViewModel
    
    @State private var selectedLevel: ServiceTechnicianMaintenanceLevel = .junior
    @State private var selectedLevelString: String = "Junior"
   
    @State private var description = ""
    @State private var dateDue = Date()
    @State private var search = ""
    @State private var selectedAirplane: Airplane? 
    @State private var  isOrderComplete = false
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Flugzeug suchen", text: $search)
                    .onChange(of: search) { newValue in
                        createServiceRequestViewModel.searchAirplanes(withName: newValue)
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if createServiceRequestViewModel.isSearching {
                    Spacer()
                    ProgressView("Suche nach Flugzeugen...")
                    Spacer()
                } else {
                    List(createServiceRequestViewModel.airplanes, id: \.id) { airplane in
                        HStack {
                            AsyncImage(url: URL(string: airplane.imgThumb ?? "")) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 70)
                            
                            Spacer()
                            
                            Text(airplane.plane)
                            
                            Spacer()
                            
                            ZStack{
                                Image(systemName: "rectangle")
                                    .font(.title2)
                                
                                if selectedAirplane?.id == airplane.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                            .contentShape(Rectangle())
                        .onTapGesture {
                            selectedAirplane = airplane
                        }
                    }
                }
                
                TextField("Beschreibung", text: $description)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
               
                HStack{
                    Text("Service Level:")
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    Picker("Qualifikations-Level", selection: $selectedLevel) {
                        ForEach(ServiceTechnicianMaintenanceLevel.allCases) { level in
                            Text(level.rawValue)
                                .tag(level)
                                .padding(.horizontal)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedLevel) { select in
                        selectedLevelString = select.rawValue
                    }
                    
                    
                }
                
                
                DatePicker("Fälligkeitsdatum", selection: $dateDue, displayedComponents: .date)
                    .padding()
                
                Button(action: {
                    guard let airplane = selectedAirplane else { return }
                    
                    print("Adding service request for \(airplane.plane) with description: \(description) and due date: \(dateDue)")
                    serviceRequestsViewModel.createServiceRequest(
                        airplaneName: airplane.plane,
                        description: description,
                        dateDue: dateDue,
                        serviceLevel: selectedLevelString
                        
                        
                    )
                    isOrderComplete = true
               
               
                }) {
                    Label("Hinzufügen", systemImage: "plus")
                }
                .padding()
                .disabled(selectedAirplane == nil)
            }
            
            .alert("Hinweis", isPresented: $isOrderComplete) { Button("OK", role: .cancel) {} } message: { Text("Der Auftrag wurde erfolgreich angelegt.")
            }
            
            .presentationDragIndicator(.visible)
            
           
            .navigationTitle("Service Request erstellen")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


