//
//  PatientDetails.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 05.04.2021.
//

import SwiftUI

struct PatientDetails: View {
    
    @ObservedObject var patient: Patient
    
    var body: some View {
        Group {
            CustomSection(header: Text(label(.birthDateAndAge))) {
                HStack {
                    Text(patient.formattedBirthDate)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(patient.age)
                        .foregroundColor(.secondary)
                }
            }
            CustomSection(header: Text(label(.personalDetails))) {
                Text(patient.formattedPhoneNumber)
                Text(patient.formattedAddress)
                Text(patient.formattedJob)
            }
        }
    }
}

struct PatientDetails_Previews: PreviewProvider {
    static var previews: some View {
        PatientDetails(patient: Patient(using: Patient.example))
    }
}
