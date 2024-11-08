//
//  MyServiceRequestListView.swift
//  PreflightService
//
//  Created by Eggenschwiler Andre on 30.10.24.
//



import SwiftUI

struct ServiceRequestsListView: View {
    @StateObject var serviceRequestsListViewModel = ServiceRequestsListViewModel()
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    
    //    @StateObject var serviceRequestViewModel: ServiceRequestViewModel
    
    @State private var showSheet = false
    
    
    
    var body: some View {
        
        NavigationStack {
            // Zeigt alle Aufträge an, die momentan nicht bearbeitet werden
            //            if authenticationViewModel.test() == serviceRequestViewModel.serviceRequest.serviceLevel {
            List(serviceRequestsListViewModel.openServiceRequests) { serviceRequest in
                NavigationLink(
                    destination: { ServiceRequestDetailView(serviceRequest: serviceRequest) },
                    label: { ServiceRequestListItemView(serviceRequest: serviceRequest) }
                )
            }
            
            .navigationTitle("Offene Aufträge")
            
            .toolbar {
                if authenticationViewModel.user?.isLeadingTechnician == true {
                    Button("Hinzufügen", systemImage: "plus") {
                        showSheet = true
                        
                    }
                }
            }
            .sheet(isPresented: $showSheet) {
                CreateServiceRequestSheet(serviceRequestsViewModel: serviceRequestsListViewModel)
            }
            
        }
        .onAppear {
            // Ruft alle Aufträge ab, die nicht bearbeitet werden
            serviceRequestsListViewModel.fetchOpenServiceRequests()
        }
        
    }
}


#Preview {
    ServiceRequestsListView()
        .environmentObject(AuthenticationViewModel())
}
