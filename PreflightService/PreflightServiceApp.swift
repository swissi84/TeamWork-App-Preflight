//
//  PreflightServiceApp.swift
//  PreflightService
//
//  Created by Florian Rhein on 21.10.24.
//

import FirebaseCore
import SwiftUI

@main
struct PreflightServiceApp: App {
    
    @StateObject private var authenticationViewModel = AuthenticationViewModel()
    @StateObject var serviceRequestsViewModel = ServiceRequestsListViewModel()
    @StateObject var techniciansListViewModel = TechniciansListViewModel()
    
    init() {
        // Initialisierung der Firebase-App.
        // Hinweis: Das Projekt muss eine gültige GoogleService-Info.plist Datei enthalten, damit dieser Schritt funktioniert.
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            // Zeigt den `ServiceRequestsListView` an, wenn jemand angemeldet ist. Ansonsten wird der `AuthenticationView` angezeigt.
            if authenticationViewModel.isUserSignedIn {
                TabView {
                    MyServiceRequestsListView()
                    
                        .tabItem {
                            Label("Meine Aufträge", systemImage: "person.crop.circle.fill.badge.checkmark")
                        }
                    
                    ServiceRequestsListView()
                    
                        .tabItem {
                            Label("Offene Aufträge", systemImage: "questionmark.text.page")
                        }
                    }
                } else {
                AuthenticationView()
            }
        }
        .environmentObject(authenticationViewModel) // Registriert das AuthenticationViewModel für die gesamte App.
        .environmentObject(techniciansListViewModel)
        .environmentObject(serviceRequestsViewModel)
    }
}
