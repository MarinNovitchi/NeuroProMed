//
//  PatientDetailsSection.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 22.04.2021.
//

import SwiftUI

struct PatientDetailsSection: View {
    
    @Binding var patientData: Patient.PatientProperties
    let isUsedByFilter: Bool
    
    var body: some View {
        Section {
            TextField(label(.firstName), text: $patientData.firstName)
            TextField(label(.lastName), text: $patientData.lastName)
            if isUsedByFilter {
                DatePicker(label(.bornAfter), selection: $patientData.birthDateFrom, in: ...Date(), displayedComponents: .date)
                DatePicker(label(.bornBefore), selection: $patientData.birthDateTo, in: ...Date(), displayedComponents: .date)
            } else {
                DatePicker(label(.birthDate), selection: $patientData.birthDate, in: ...Date(), displayedComponents: [.date])
            }
            TextField(label(.address), text: $patientData.address)
            TextField(label(.job), text: $patientData.job)
        }
    }
}

struct PatientDetailsSection_Previews: PreviewProvider {
    static var previews: some View {
        PatientDetailsSection(patientData: .constant(Patient.example), isUsedByFilter: false)
    }
}
