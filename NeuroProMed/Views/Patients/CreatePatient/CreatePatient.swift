//
//  AddPatientView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.03.2021.
//

import SwiftUI

struct CreatePatient: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        Form {
            PatientDetailsSection(patientData: $viewModel.patientData, isUsedByFilter: false)
        }
        .onReceive(viewModel.dismissView) { isDismissed in
            if isDismissed {
                dismiss()
            }
        }
        .navigationTitle(label(.createPatient))
        .navigationBarItems(
            leading: Button(label(.cancel)) { dismiss() },
            trailing: Button(label(.save)) { viewModel.createPatient() }
                .disabled(viewModel.patientData.firstName.isEmpty || viewModel.patientData.lastName.isEmpty)
        )
        .alert(isPresented: $viewModel.isShowingAlert) {
            Alert(
                title: Text(label(.error)),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK")))
        }
    }
}

struct AddPatientView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePatient(viewModel: .init())
    }
}
