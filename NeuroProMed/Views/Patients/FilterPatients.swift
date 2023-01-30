//
//  FilterPatients.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 04.04.2021.
//

import SwiftUI

extension FilterPatients {
    
    class ViewModel: ObservableObject {
        
        @Published var filterData = Patient.PatientProperties()
        
        @Published var alertMessage = ""
        @Published var isShowingAlert = false
        
        func applyFilter() {
    //        patients.filterPatients(using: filterData) { response in
    //            let generator = UINotificationFeedbackGenerator()
    //            switch response {
    //            case .success(let rs):
    //                self.patients.patients = rs
    //                isFilterApplied = true
    //                presentationMode.wrappedValue.dismiss()
    //            case .failure(let error):
    //                error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
    //            }
    //        }
        }
        
        func removeFilter() {
    //        patients.load() { response in
    //            let generator = UINotificationFeedbackGenerator()
    //            switch response {
    //            case .success(let rs):
    //                self.patients.patients = rs
    //                isFilterApplied = false
    //                presentationMode.wrappedValue.dismiss()
    //            case .failure(let error):
    //                error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
    //            }
    //        }
        }
    }
}

struct FilterPatients: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ViewModel
    @Binding var isFilterApplied: Bool

    
    var body: some View {
        Form {
            PatientDetailsSection(patientData: $viewModel.filterData, isUsedByFilter: true)
            if isFilterApplied {
                ListButton(title: label(.removeFilter), action: viewModel.removeFilter)
            }
        }
        .navigationTitle(label(.filterPatients))
        .navigationBarItems(
            leading: Button(label(.cancel)) { dismiss() },
            trailing: Button(label(.filterAction), action: viewModel.applyFilter)
        )
    }
}

struct FilterPatients_Previews: PreviewProvider {
    static var previews: some View {
        FilterPatients(viewModel: .init(), isFilterApplied: .constant(true))
    }
}
