//
//  AddPatientView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.03.2021.
//

import SwiftUI

extension CreatePatient {
    
    class ViewModel: ObservableObject {
        
        @Published var patientData = Patient.PatientProperties()
        
        @Published var alertMessage = ""
        @Published var isShowingAlert = false

        func createPatient() {
    //        let newPatient = Patient(using: patientData)
    //        newPatient.create() { response in
    //            let generator = UINotificationFeedbackGenerator()
    //            switch response {
    //                case .success:
    //                    patients.patients.insert(newPatient, at: 0)
    //                    generator.notificationOccurred(.success)
    //                    presentationMode.wrappedValue.dismiss()
    //            case .failure(let error):
    //                error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
    //            }
    //        }
        }
        
    }
}

struct CreatePatient: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        Form {
            PatientDetailsSection(patientData: $viewModel.patientData, isUsedByFilter: false)
        }
        .navigationTitle(label(.createPatient))
        .navigationBarItems(
            leading: Button(label(.cancel)) { dismiss() },
            trailing: Button(label(.save), action: viewModel.createPatient)
                .disabled(viewModel.patientData.firstName.isEmpty || viewModel.patientData.lastName.isEmpty)
        )
        .alert(isPresented: $viewModel.isShowingAlert) {
            Alert(title: Text(label(.error)), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct AddPatientView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePatient(viewModel: .init())
    }
}
