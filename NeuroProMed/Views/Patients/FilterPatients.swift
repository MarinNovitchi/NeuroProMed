//
//  FilterPatients.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 04.04.2021.
//

import SwiftUI

struct FilterPatients: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var patients: Patients
    
    @Binding var isFilterApplied: Bool
    @State private var filterData = Patient.PatientProperties()
    
    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    
    func applyFilter() {
        patients.filterPatients(using: filterData) { response in
            let generator = UINotificationFeedbackGenerator()
            switch response {
            case .success(let rs):
                self.patients.patients = rs
                isFilterApplied = true
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
            }
        }
    }
    
    func removeFilter() {
        patients.load() { response in
            let generator = UINotificationFeedbackGenerator()
            switch response {
            case .success(let rs):
                self.patients.patients = rs
                isFilterApplied = false
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
            }
        }
    }
    
    var body: some View {
        Form {
            PatientDetailsSection(patientData: $filterData, isUsedByFilter: true)
            if isFilterApplied {
                ListButton(title: label(.removeFilter), action: removeFilter)
            }
        }
        .navigationTitle(label(.filterPatients))
        .navigationBarItems(
            leading: Button(label(.cancel)) { presentationMode.wrappedValue.dismiss() },
            trailing: Button(label(.filterAction), action: applyFilter)
        )
    }
}

struct FilterPatients_Previews: PreviewProvider {
    static var previews: some View {
        FilterPatients(patients: Patients(), isFilterApplied: .constant(true))
    }
}
