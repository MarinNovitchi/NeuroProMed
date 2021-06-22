//
//  PatientRow.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 04.04.2021.
//

import SwiftUI

struct PatientRow: View {
    
    @ObservedObject var patient: Patient
    
    var body: some View {
        Image(systemName: "person")
        VStack (alignment: .leading) {
            HStack {
                Text(patient.firstName)
                Text(patient.lastName).bold().padding(.leading, -4)
            }
                .foregroundColor(.primary)
            Text(patient.formattedBirthDate)
                .foregroundColor(.secondary)
        }
    }
}

struct PatientRow_Previews: PreviewProvider {
    static var previews: some View {
        PatientRow(patient: Patient(using: Patient.example))
    }
}
