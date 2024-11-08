//
//  PasswordToggleField.swift
//  PreflightService
//
//  Created by Florian Rhein on 21.10.24.
//

import SwiftUI

// Eine View, um in einem Passworteingabefeld zwischen Klartext und maskiertem Text zu wechseln.
struct PasswordToggleField: View {
    @Binding var password: String

    @State private var isPasswordVisible = false

    var body: some View {
        ZStack(alignment: .trailing) {
            if isPasswordVisible {
                TextField("Passwort", text: $password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
            } else {
                SecureField("Passwort", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
            }
            Button("", systemImage: isPasswordVisible ? "eye" : "eye.slash") {
                isPasswordVisible.toggle()
            }
            .padding(.trailing)
        }
    }
}

#Preview {
    PasswordToggleField(password: .constant(""))
}
