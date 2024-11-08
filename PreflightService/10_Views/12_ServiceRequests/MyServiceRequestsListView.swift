//
//  ServiceRequestsListView.swift
//  PreflightService
//
//  Created by Florian Rhein on 21.10.24.
//

import SwiftUI

struct MyServiceRequestsListView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @StateObject private var serviceRequestsViewModel = ServiceRequestsListViewModel()
    
    var body: some View {
        NavigationStack {
            HStack {
                Image(systemName: "wrench.and.screwdriver")
                Text("Service Level: \(authenticationViewModel.getServiceLevel())")
                    .font(.headline)
                    
                Spacer()
            }
            .padding()
           List(serviceRequestsViewModel.serviceRequestsForCurrentTechnician) { serviceRequest in
                NavigationLink(
                    destination: { ServiceRequestDetailView(serviceRequest: serviceRequest) },
                    label: { ServiceRequestListItemView(serviceRequest: serviceRequest) }
                )
                
                
            }
            .navigationTitle("Meine Aufträge")
            
            .toolbar {
                Button("Abmelden") {
                        authenticationViewModel.signOut()
                    }
                }
            
            .onAppear {
                Task {
                    await serviceRequestsViewModel.fetchServiceRequets(for: authenticationViewModel.user)
                }
            }
            
        }
    }
}
       


#Preview {
    MyServiceRequestsListView()
        .environmentObject(AuthenticationViewModel())
}

