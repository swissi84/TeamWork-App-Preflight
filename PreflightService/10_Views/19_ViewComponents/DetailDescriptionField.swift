//
//  DetailDescriptionField.swift
//  PreflightService
//
//  Created by Florian Rhein on 22.10.24.
//

import SwiftUI

// Eine View zum Anzeigen von Textdaten in einer Auflistung
struct DetailDescriptionField: View {
    let labelText: String
    let content: String

    var body: some View {
        HStack(alignment: .top) {
            Text(labelText)
                .bold()
            Spacer()
            Text(content)
                .multilineTextAlignment(.leading)
        }
        .padding(5)
    }
}

#Preview {
    DetailDescriptionField(labelText: "Beschreibung", content: "Perform a comprehensive inspection and scheduled maintenance on aircraft model , focusing on airframe integrity and avionics systems functionality. Check and replace all hydraulic lines and fluid reservoirs as per manufacturer’s guidelines. Conduct a full engine diagnostic, including compression tests and turbine blade inspections. Verify proper operation of navigation and communication systems, recalibrating sensors where necessary. Additionally, ensure that all safety equipment, including oxygen systems and fire suppression units, are tested and certified for operational readiness.")
}
