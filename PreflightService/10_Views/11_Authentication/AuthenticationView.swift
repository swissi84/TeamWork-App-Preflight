//
//  AuthenticationView.swift
//  PreflightService
//
//  Created by Florian Rhein on 21.10.24.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    
    @State private var email = ""
    @State private var password = ""
    
    @State private var newAccountName = ""
    @State private var newAccountPhoneNumber = ""
    @State private var newAccountMaintenanceLevel: ServiceTechnicianMaintenanceLevel?
    @State private var newAccountEmail = ""
    @State private var newAccountPassword = ""
    @State private var newAccountPasswordConfirmation = ""
   
    @State private var showRegistrationSheet = false
    @State private var isEmailAlert = false
    @State private var isPasswortAlert = false
    @State private var isMatchPasswort = false
    @State private var isNotEmpty = false
    @State private var isPhoneNumberAlert = false
    
    func maintenanceLevel() {
        newAccountMaintenanceLevel = .junior
    }
    
    
    
    
    var body: some View {
        VStack {
            Image(.preflightService)
                .resizable()
                .padding(-45)
                .offset(x: 0, y: 7)
                .frame(width: 200, height: 200)
                .clipShape(Circle())
            
            Text("PreflightService")
                .font(.title)
                .fontDesign(.serif)
            Text("by Rheinland Aviation Ltd.")
                .italic()
                .font(.subheadline)
            
            TextField("Email-Adresse", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.clear)
                    .frame(width: 210, height: 35)
                
                if !authenticationViewModel.isValidEmail(email) && !email.isEmpty    {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white.opacity(0.8))
                        .frame(width: 210, height: 35)
                    Text("Ungültige Email Adresse!")
                        .foregroundColor(.red)
                }
            }
            
            PasswordToggleField(password: $password)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.clear)
                    .frame(width: 210, height: 35)
                
                if !authenticationViewModel.isValidPassword(password) && !password.isEmpty {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white.opacity(0.9))
                    
                        .frame(width: 210, height: 35)
                    Text("Ungültiges Passwort!")
                        .foregroundColor(.red)
                }
                
            }
            Spacer()
            VStack{
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white .opacity(0.9))
                        .frame(width: 220, height: 40)
                        .padding()
                        .shadow(radius: 5, x: 5,y: 5)
                    
                    Button("Anmelden") {
                        authenticationViewModel.signIn(email: email, password: password)
                        
                    }
                    .foregroundStyle(.black)
                    .font(.title2)
                }
            }
            Spacer()
                .padding()
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white .opacity(0.9))
                    .frame(width: 220, height: 40)
                    .padding()
                    .shadow(radius: 5, x: 5,y: 5)
                
                Button("Account erstellen \(Image(systemName: "person.crop.circle.badge.plus"))") {
                    showRegistrationSheet = true
                }
                .foregroundStyle(.black)
                .font(.title2)
                
            }
        }
        .background {
            Image(.airplaneBackground)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 3)
        }
        .sheet(isPresented: $showRegistrationSheet) {
            // Sheet zur Anzeige eines
            Form {
                Section("Persönliche Daten") {
                    TextField("Name", text: $newAccountName)
                    TextField("Telefonnummer", text: $newAccountPhoneNumber)
                  
                    Picker("Qualifikations-Level", selection: $newAccountMaintenanceLevel) {
                        ForEach(ServiceTechnicianMaintenanceLevel.allCases, id: \.rawValue) { level in
                            Text(level.rawValue)
                                .tag(level)
                        }
                    }
                }
                
                Section("Anmeldedaten") {
                    TextField("Email", text: $newAccountEmail)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    SecureField("Passwort", text: $newAccountPassword)
                    SecureField("Passwort wiederholen", text: $newAccountPasswordConfirmation)
                    Button("Account erstellen") {
                        if !newAccountName.isEmpty && !newAccountPhoneNumber.isEmpty && !newAccountEmail.isEmpty && !newAccountPassword.isEmpty {
                           if authenticationViewModel.isValidEmail(newAccountEmail) {
                                if authenticationViewModel.isValidPassword(newAccountPassword) {
                                    if newAccountPassword == newAccountPasswordConfirmation {
                                        if authenticationViewModel.isValidPhoneNumber(newAccountPhoneNumber) {
                                            authenticationViewModel.register(
                                                email: newAccountEmail,
                                                password: newAccountPassword,
                                                passwordConfirmation: newAccountPasswordConfirmation,
                                                name: newAccountName,
                                                maintenanceLevel: newAccountMaintenanceLevel,
                                                phoneNumber: newAccountPhoneNumber
                                            )
                                            
                                        } else {
                                            isPhoneNumberAlert = true
                                            print("Phonenumber failed")
                                        }
                                       
                                    } else {
                                        isMatchPasswort = true
                                        print("Passwort Match failed")
                                    }
                                        } else {
                                    isPasswortAlert = true
                                    print("Passwort failed")
                                }
                            } else {
                                isEmailAlert = true
                                print("Emal failed")
                            }
                        } else {
                            isNotEmpty = true
                            print("isNotEmpty failed")
                        }
                    }
                }
                .alert("Hinweis", isPresented: $isPhoneNumberAlert) { Button("OK", role: .cancel) {} } message: { Text("Eingegebene Telefonnummer ist ungültig!")
                }
                .alert("Hinweis", isPresented: $isMatchPasswort) { Button("OK", role: .cancel) {} } message: { Text("Eingegeben Passwort sind unterschiedlich!")
                }
                .alert("Passwort ungültig", isPresented: $isPasswortAlert) { Button("OK", role: .cancel) {} } message: { Text("min. 6 Zeichen sowie Buchstaben und Zahlen enthalten!")
                }
                
                .alert("Email ungültig", isPresented: $isEmailAlert) { Button("OK", role: .cancel) {} } message: { Text("nur mit der Endung gültig:    @rheinland-aviation.com")
                }
                
                .alert("Hinweis", isPresented: $isNotEmpty) { Button("OK", role: .cancel) {} } message: { Text("Alle Felder müssen ausgefüllt werden!")
                }
            }
        }
        .onAppear {
            maintenanceLevel()
        }
        
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationViewModel())
}
