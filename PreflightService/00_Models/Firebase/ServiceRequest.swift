//
//  ServiceRequest.swift
//  PreflightService
//
//  Created by Florian Rhein on 21.10.24.
//

import FirebaseFirestore
import Foundation

// Bildet einen Wartungsauftrag ab, wie er in FirebaseFirestore gespeichert werden soll
struct ServiceRequest: Codable, Identifiable {
    @DocumentID var id: String? // ID dieses Datensatzes (von Firestore vergeben)
    let airplaneName: String // Modellbezeichnung des Flugzeugs, das gewartet werden soll
    let servicedByUserId: String? // Techniker:in, der/die momentan diesen Wartungsauftrag bearbeitet (kein Wert bedeutet: der Wartungsauftrag wird noch nicht bearbeitet)
    let description: String // Beschreibung der Wartungsarbeiten
    let dateCreated: Date // Erstellungszeitpunkt des Wartungsauftrags
    let dateDue: Date // Datum, zu dem der Wartungsauftrag erledigt werden muss
    let dateCompleted: Date? // Datum, zu dem der Wartungsauftrag abgeschlossen wurde (kein Wert bedeutet: der Wartungsauftrag ist noch nicht abgeschlossen)
    let serviceLevel: String
}
