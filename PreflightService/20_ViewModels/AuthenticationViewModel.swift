//
//  AuthenticationViewModel.swift
//  PreflightService
//
//  Created by Florian Rhein on 21.10.24.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published private(set) var user: ServiceTechnician?
    @Published private(set) var errorMessage: String?

    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()

    
    
    var isUserSignedIn : Bool {
        self.user != nil
    }

    init() {
        self.checkLogin()
    }

    func getServiceLevel() -> String {
        let level = user?.maintenanceLevel.rawValue ?? "unbekannt"
        return level
    }


   
    func isValidEmail(_ email: String) -> Bool {
       return email.hasSuffix("@rheinland-aviation.com")
    }

    
    
    
    func isValidPassword(_ password: String) -> Bool {
           let hasletter = password.range(of: "[A-Za-z]", options: .regularExpression) != nil
           let hasnumber = password.range(of: "[0-9]", options: .regularExpression) != nil
           let count = password.count >= 6
           
           return count && hasletter && hasnumber
    }
    
    func isValidPhoneNumber(_ number: String) -> Bool {
        let numberCheck = number.range(of: "^[\\+]?[0-9-\\s]{4,20}$", options: .regularExpression) != nil
            
            return numberCheck
        }
    
    
    
    
    func register(email: String, password: String, passwordConfirmation: String, name: String, maintenanceLevel: ServiceTechnicianMaintenanceLevel?, phoneNumber: String) {

        // 1. Validierungen der Nutzer-Eingaben...
        guard let maintenanceLevel else {
            self.errorMessage = "Bitte geben Sie ein Qualifikations-Level an.\nWenn Sie nicht sicher sind, welches Qualifikations-Level Sie erfüllen, wenden Sie sich an Ihren Leading Technician."
            return
        }

// MARK: -
 /**       Der reguläre Ausdruck ^[\\+]?[0-9-\\s]{4,12}$ hat folgende Bedeutung:

            ^: Dies ist ein Anker, der den Beginn der Zeichenkette markiert. Der Ausdruck muss also am Anfang der Zeichenkette beginnen.
            [\\+]?: Dies bedeutet, dass ein Pluszeichen (+) optional am Anfang der Zeichenkette stehen kann. Das Fragezeichen (?) zeigt an, dass das vorhergehende Zeichen (in diesem Fall das Pluszeichen) null oder einmal vorkommen kann.
            [0-9-\\s]{4,12}: Dieser Teil des Ausdrucks beschreibt eine Gruppe von Zeichen, die aus Ziffern (0-9), Bindestrichen (-) und Leerzeichen (\\s) bestehen kann. Die geschweifte Klammer {4,12} gibt an, dass diese Gruppe zwischen 4 und 12 Zeichen lang sein muss.
            $: Dies ist ein Anker, der das Ende der Zeichenkette markiert. Der Ausdruck muss also am Ende der Zeichenkette enden.

        Zusammenfassung
        Insgesamt bedeutet dieser reguläre Ausdruck, dass er eine Zeichenkette validiert, die optional mit einem Pluszeichen beginnt, gefolgt von 4 bis 12 Zeichen, die Ziffern, Bindestriche oder Leerzeichen sein können. Beispiele für gültige Zeichenketten wären +1234, 123-456, oder 1234 5678.
  */
        guard phoneNumber.range(of: "^[\\+]?[0-9-\\s]{4,20}$", options: .regularExpression) != nil else {
            self.errorMessage = "Die Telefonnummer entspricht nicht dem erwarteten Format. Die Telefonnummer kann mit einem Pluszeichen beginnen, darf nur Ziffern, Bindestriche oder Leerzeichen enthalten und muss zwischen 4 und 20 Stellen lang sein"
            return
        }

        guard password == passwordConfirmation && password.count > 6 else {
            self.errorMessage = "Beide Passwortfelder müssen übereinstimmen. Das Passwort muss länger als 6 Zeichen sein"
            return
        }
    
        // Die Account-Erstellung findet in einem Task statt, damit wir die asynchrone `createUser`-Funktion von FirebaseAuth verwenden können
        // Alternativ könnte man die Funktion mit einer Closure benutzen, aber durch die asynchrone Funktion wird der Kontrollfuss besser lesbar
        Task {
            do {
                // 2. Anlegen des Accounts in FirebaseAuth...
                let firebaseUser = try await auth.createUser(withEmail: email, password: password)

                // 3. Erstellen des Benutzerprofils in FirebaseFirestore...
                // TODO: ggf. in Repository auslagern?
                let userId = firebaseUser.user.uid
                let newServiceTechnician = ServiceTechnician(
                    userId: userId,
                    email: email,
                    name: name,
                    phoneNumber: phoneNumber,
                    maintenanceLevel: maintenanceLevel
                )
                try firestore.collection("serviceTechnicians").document(userId).setData(from: newServiceTechnician)

                // 4. Zuweisen des erstellten Benutzers zur User-Variable, womit UI-Änderungen ausgelöst werden können
                self.user = newServiceTechnician
            } catch {
                self.errorMessage = "Benutzer konnte nicht erstellt werden: \(error)"
            }
        }
    }

    func signIn(email: String, password: String) {
        // Die Anmeldung findet in einem Task statt, damit wir die asynchrone `signIn`-Funktion von FirebaseAuth und die asynchrone `getDocument()`-Funktion von FirebaseFirestore verwenden können
        // Alternativ könnte man die Funktionen mit einer Closure benutzen, aber durch die asynchronen Funktionen wird der Kontrollfuss besser lesbar
        Task {
            do {
                // 1. Anmelden des Benutzers in FirebaseAuth...
                let firebaseUser = try await auth.signIn(withEmail: email, password: password)

                // 2. Abrufen des gespeicherten Benutzerprofils aus FirebaseFirestore
                // TODO: ggf. in Repository auslagern?
                let userId = firebaseUser.user.uid
                let document = try await firestore.collection("serviceTechnicians").document(userId).getDocument()
                let serviceTechnician = try document.data(as: ServiceTechnician.self)

                // 4. Zuweisen des angemeldenten Benutzers zur User-Variable, womit UI-Änderungen ausgelöst werden können
                self.user = serviceTechnician
            } catch {
                self.errorMessage = "Benutzer konnte nicht angemeldet werden: \(error)"
            }
        }
    }

    func signOut() {
        do {
            // 1. Abmelden aus FirebaseAuth...
            try auth.signOut()
            // 2. user-Variable zurücksetzen, womit UI-Änderungen ausgelöst werden können
            self.user = nil
        } catch {
            self.errorMessage = "Benutzer konnte nicht abgemeldet werden: \(error)"
        }
    }

    private func checkLogin() {
        // 1. Prüfen, ob in FirebaseAuth bereits ein Benutzer angemeldet ist...
        guard let currentUser = auth.currentUser else { return }

        Task {
            do {
                // 2. Abrufen des gespeicherten Benutzerprofils aus FirebaseFirestore
                // TODO: ggf. in Repository auslagern?
                let document = try await firestore.collection("serviceTechnicians").document(currentUser.uid).getDocument()
                let serviceTechnician = try document.data(as: ServiceTechnician.self)

                // 4. Zuweisen des angemeldenten Benutzers zur User-Variable, womit UI-Änderungen ausgelöst werden können
                self.user = serviceTechnician
            } catch {
                self.errorMessage = "Benutzer konnte nicht angemeldet werden: \(error)"
            }
        }
    }
}
