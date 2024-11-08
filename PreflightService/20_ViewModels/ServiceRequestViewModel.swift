//
//  ServiceRequestViewModel.swift
//  PreflightService
//
//  Created by Florian Rhein on 22.10.24.
//

import Foundation
import SwiftUI


// Dieses ViewModel bereitet Daten für das Anzeigen eines _einzelnen_ Wartungsauftrags auf, entweder als Listeneintrag, oder in einer Detailansicht.
@MainActor
class ServiceRequestViewModel: ObservableObject {

    // Bildet den Status den Wartungsauftrags ab, wie er auf der UI angezeigt werden soll
    enum ServiceRequestStatus {
        case urgent // Dringlich: der Wartungsauftrag ist bald fällig
        case open // Offen: der Wartungsauftrag wird noch von niemandem bearbeitet
        case inProgress // In Bearbeitung: Der Wartungsauftrag wird momentan bearbeitet
        case completed // Abgeschlsosen: Der Wartungsauftrag wurde erfolgreich abgeschlossen

        // Der deutschsprachige Text, der zum jeweiligen Status gehört
        var displayText: String {
            switch self {
                case .urgent:
                    "Dringend"
                case .open:
                    "Offen"
                case .inProgress:
                    "In Bearbeitung"
                case .completed:
                    "Abgeschlossen"
            }
        }

        // Name des systemImage, das zum jeweiligen Wartungsauftrag gehört
        var systemImage: String {
            switch self {
                case .urgent:
                    "clock.badge.exclamationmark"
                case .open:
                    "tray.and.arrow.up"
                case .inProgress:
                    "wrench.and.screwdriver"
                case .completed:
                    "checklist.checked"
            }
        }

        // Farbe, die zum jeweiligen Wartungsauftrag gehört
        var statusBadgeColor: Color {
            switch self {
                case .urgent:
                    Color.red
                case .open:
                    Color.orange
                case .inProgress:
                    Color.gray
                case .completed:
                    Color.green
            }
        }
    }

    @Published private(set) var serviceRequest: ServiceRequest
    @Published private(set) var airplane: Airplane?
    @Published private(set) var serviceTechnician: ServiceTechnician?

    // Bestimmt den Statuseines Wartungsauftrags, wie er auf der UI angezeigt wird
    var serviceRequestStatus: ServiceRequestStatus {
        // Wenn der Wartungsauftrag ein `dateCompleted` hat, ist er abgeschlossen
        if serviceRequest.dateCompleted != nil {
            return .completed
        }

        // Wenn der Wartungsauftrag eineM/einer Techniker:in zugewiesen ist, ist er in Bearbeitung
        if serviceRequest.servicedByUserId != nil {
            return .inProgress
        }

        // Wenn das Erledigungsdatum weniger als 7 Tage in der Zuklunft liegt, ist der Auftrag dringlich
        let urgencyDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        if let urgencyDate, serviceRequest.dateDue <= urgencyDate {
            return .urgent
        }

        // Wenn keine der obigen Bedingungen zutrifft, ist der Auftrag offen
        return .open
    }

    private let airplaneApiRepository = AirplaneAPIRepository()
    private let serviceTechnicianRepository = ServiceTechnicianFirebaseRepository()
    private let serviceRequestsRepository = ServiceRequestsFirebaseRepository()

    init(serviceRequest: ServiceRequest) {
        self.serviceRequest = serviceRequest
    }

    // Ruft für den Wartungsauftrag die Daten zum dazugehörigen Flugzeugt von einer API ab
    func fetchAirplaneData() {
        Task {
            do {
                self.airplane = try await self.airplaneApiRepository.getAirplanes(byName: serviceRequest.airplaneName).first
            } catch {
                print(error)
            }
        }
    }

    // Prüft, ob er Wartungsauftrag von einem/einer Techniker:in angenommen werden kann
    // Der Auftrag kann nur angenommen werden, wenn er im Status "Offen" oder "Dringlich" ist.
    func canBeAssigned(to serviceTechnician: ServiceTechnician?) -> Bool {
        switch serviceRequestStatus {
            case .urgent, .open:
                true
            case .inProgress, .completed:
                false
        }
    }

    // Weist den Wartungsauftrag dem/der übergebenen Techniker:in zu.
    // Ruft den Wartungsauftrag anschließend erneut aus dem Firestore ab.
    func assignServiceRequest(to serviceTechnician: ServiceTechnician?) {
        guard let serviceTechnician else { return }

        serviceRequestsRepository.assignServiceRequest(self.serviceRequest, toTechnician: serviceTechnician)
        self.reevaluateServiceRequest()
    }

    // Prüft, ob er Wartungsauftrag von einem/einer Techniker:in abgeschlossen werden kann
    // Der Auftrag kann nur abgeschlossen werden, wenn er momentan von der jeweiligen Techniker:in bearbeitet wird und sich im Status "In Bearbeitung" befindet
    func canBeCompleted(by serviceTechnician: ServiceTechnician?) -> Bool {
        guard let serviceTechnician else { return false }

        if
            serviceTechnician.userId == serviceRequest.servicedByUserId,
            case .inProgress = serviceRequestStatus
        {
            return true
        }

        return false
    }

    // Schließt den Wartungsauftrag ab.
    // Ruft den Wartungsauftrag anschließend erneut aus dem Firestore ab.
    func completeServiceRequest() {
        serviceRequestsRepository.completeServiceRequest(self.serviceRequest)
        self.reevaluateServiceRequest()
    }

    // Ruft den Wartungsauftrag erneut aus dem Firestore ab, damit Änderungen auf der UI sichtbar werden
    private func reevaluateServiceRequest() {
        Task {
            if let serviceRequest = try await serviceRequestsRepository.getServiceRequest(withId: serviceRequest.id) {
                self.serviceRequest = serviceRequest
            }
        }
    }
}
