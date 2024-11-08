//
//  ServiceRequestsFirebaseRepository.swift
//  PreflightService
//
//  Created by Florian Rhein on 21.10.24.
//

import FirebaseFirestore
import Foundation

class ServiceRequestsFirebaseRepository {
    private let firestore = Firestore.firestore()

    // MARK: - Create functions

    func createNewServiceRequest(airplaneName: String, description: String, dateDue: Date, serviceLevel: String) throws {
        firestore
            .collection("serviceRequests")
            .addDocument(
                data: [ // pass the data as dictionary instead of encodable model, because we otherwise cannot save null values
                    "airplaneName": airplaneName,
                    "servicedByUserId": NSNull(), // using "NSNull()" here instead of "nil", so firebase will save this value as "null" (using nil will just omit the field)
                    "description": description,
                    "dateCreated": Date(),
                    "dateDue": dateDue,
                    "dateCompleted": NSNull(), // using "NSNull()" here instead of "nil", so firebase will save this value as "null" (using nil will just omit the field)
                    "serviceLevel": serviceLevel
                      ]
            )
    }


    // MARK: - Read functions

    // Verwendet einen Firestore Listener, um Änderungen an den gespeicherten Wartungsaufträgen abzurufen.
    // Ruft ausschließlich Wartungsaufträge ab, die noch nicht bearbeitet werden und nicht abgeschlossen sind.
    // Die `onChange`-Closure, die an diese Funktion übergeben wird, wird aufgerufen, sobald eine Änderung festgestellt wurde
    func startServiceRequestsListenerForOpenRequests(_ onChange: @escaping ([ServiceRequest]) -> Void) {
        firestore
            .collection("serviceRequests") // fetch all ServiceRequests...
            .whereField("servicedByUserId", isEqualTo: NSNull()) // ... which are currently not serviced by anyone
            .whereField("dateCompleted", isEqualTo: NSNull()) // ... and which are not completed yet
            .addSnapshotListener { snapshot, error in
                if let error {
                    print("Failed to read serviceRequests: \(error)")
                }

                guard let snapshot else { return }

                let serviceRequests = snapshot.documents.compactMap {
                    try? $0.data(as: ServiceRequest.self)
                }

                onChange(serviceRequests)
            }
    }

    // Verwendet einen Firestore Listener, um Änderungen an den gespeicherten Wartungsaufträgen abzurufen.
    // Ruft ausschließlich Wartungsaufträge ab, die von dem/der übergebenen Servicetechniker:in bearbeitet werden.
    // Die `onChange`-Closure, die an diese Funktion übergeben wird, wird aufgerufen, sobald eine Änderung festgestellt wurde
    func startServiceRequestsListenerForTechnician(_ serviceTechnician: ServiceTechnician, _ onChange: @escaping ([ServiceRequest]) -> Void) {
        firestore
            .collection("serviceRequests")
            .whereField("servicedByUserId", isEqualTo: serviceTechnician.userId)
            .addSnapshotListener { snapshot, error in
                if let error {
                    print("Failed to read serviceRequests: \(error)")
                }

                guard let snapshot else { return }

                let serviceRequests = snapshot.documents.compactMap {
                    try? $0.data(as: ServiceRequest.self)
                }

                onChange(serviceRequests)
            }
    }

    // Ruft einen bestimmten Wartungsauftrag zu einer Id ab, solange die Id nicht `nil` ist.
    // Hinweis: verwendet die asynchrone `getDocument()`-Funktion vom Firestore, statt der `getDocument()`-Funktion mit Closure,
    // damit diese Repository-Funktion leichter vom ViewModel aufgerufen werden kann.
    func getServiceRequest(withId id: String?) async throws -> ServiceRequest? {
        guard let id else { return nil }

        let document = try await firestore
            .collection("serviceRequests")
            .document(id)
            .getDocument()

        return try document.data(as: ServiceRequest.self)
    }

    // MARK: - Update functions

    // Aktualisiert den übergebenen Wartungsauftrag, indem die ID der/des übergebenen Techniker:in in das Feld `servicedByUserId` geschrieben wird
    func assignServiceRequest(_ serviceRequest: ServiceRequest, toTechnician technician: ServiceTechnician) {
        guard let serviceRequestId = serviceRequest.id else { return }
        firestore
            .collection("serviceRequests")
            .document(serviceRequestId)
            .updateData(
                ["servicedByUserId": technician.userId]
            )
    }

    // Schließt den übergebenen Wartungsauftrag ab, indem das Feld `dateCompleted` auf das aktuelle Datum gesetzt wird
    func completeServiceRequest(_ serviceRequest: ServiceRequest) {
        guard let serviceRequestId = serviceRequest.id else { return }

        firestore
            .collection("serviceRequests")
            .document(serviceRequestId)
            .updateData(
                ["dateCompleted": Date()]
            )
    }

    // MARK: - Delete functions

    // Löscht den übergebenen Wartungsauftrag
    func deleteServiceRequest(_ serviceRequest: ServiceRequest) {
        guard let serviceRequestId = serviceRequest.id else { return }

        firestore
            .collection("serviceRequests")
            .document(serviceRequestId)
            .delete()
    }
}
