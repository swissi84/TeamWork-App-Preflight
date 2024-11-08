//
//  AssignRequestSheetView.swift
//  PreflightService
//
//  Created by mario loesel on 31.10.24.
//

import SwiftUI



struct AssignRequestSheetView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @EnvironmentObject var techniciansListViewModel: TechniciansListViewModel
    
    @ObservedObject var serviceRequestsViewModel: ServiceRequestViewModel
    
    @State private var selectedTechnician: ServiceTechnician?
    @State private var showAssingOrder: Bool = false
   
    
    var body: some View {
        NavigationStack {
            VStack {
                List(techniciansListViewModel.allTechnicians, id: \.id) { technician in
                    HStack {
                        Text(technician.name)
                            .padding()
                            .bold()
                        
                        Spacer()
                        
                        VStack(alignment: .center) {
                            Text("Level: \(technician.maintenanceLevel.rawValue)")
                                .font(.subheadline)
                                .padding(5)
                            
                            Text("Telefon: \(technician.phoneNumber)")
                                .font(.subheadline)
                        }
                    }
                    .background(selectedTechnician == technician ? Color.blue.opacity(0.2) : Color.clear)
                    .onTapGesture {
                        selectedTechnician = (selectedTechnician == technician) ? nil : technician
                    }
                }
                .onAppear {
                    Task {
                        await techniciansListViewModel.fetchAllTechnicians()
                    }
                }
                
                Button(action: {
                    if let technician = selectedTechnician {
                        serviceRequestsViewModel.assignServiceRequest(to: technician)
                    }
                    showAssingOrder = true
                }) {
                    Text("Zuweisen")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedTechnician == nil ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(selectedTechnician == nil)
            }
           
            .alert("Hinweis", isPresented: $showAssingOrder) { Button("OK", role: .cancel) {} } message: { Text("Der Auftrag wurde erfolgreich hinzugefügt.")
            }
            
            
            .presentationDragIndicator(.visible)
            .navigationTitle("Auftrag zuweisen")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
