//
//  ServiceRequestListItemView.swift
//  PreflightService
//
//  Created by Florian Rhein on 22.10.24.
//

import SwiftUI

struct ServiceRequestListItemView: View {

    @ObservedObject private var serviceRequestViewModel: ServiceRequestViewModel

    // Initialisert diese View, indem ein ServiceRequestViewModel für den übergebenen Wartungsauftrag erzeugt wird
    init(serviceRequest: ServiceRequest) {
        self._serviceRequestViewModel = .init(wrappedValue: .init(serviceRequest: serviceRequest))
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(serviceRequestViewModel.serviceRequest.dateDue.formatted(date: .abbreviated, time: .omitted))
                    .fontWeight(.bold)
                Text(serviceRequestViewModel.serviceRequest.airplaneName)
                    .italic()
                Text(serviceRequestViewModel.serviceRequest.description)
                    .lineLimit(1)
            }
            Spacer()
           
            VStack {
                Image(systemName: serviceRequestViewModel.serviceRequestStatus.systemImage)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)
                    .background {
                        Capsule()
                            .foregroundStyle(serviceRequestViewModel.serviceRequestStatus.statusBadgeColor)
                    }
            }
        }
    }
}

#Preview {
    ServiceRequestListItemView(
        serviceRequest: .init(
            airplaneName: "A380-800",
            servicedByUserId: "nil",
            description: "Preflight engine check",
            dateCreated: Date(),
            dateDue: Date().addingTimeInterval(3600),
            dateCompleted: nil,
            serviceLevel: "junior"
            
        )
    )
}
