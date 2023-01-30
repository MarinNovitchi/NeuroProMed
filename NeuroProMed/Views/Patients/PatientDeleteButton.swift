//
//  PatientDeleteButton.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 05.04.2021.
//

import SwiftUI

extension PatientDeleteButton {
    
    class ViewModel: ObservableObject {
        
        @Published var alertMessage = ""
        @Published var activeAlert: ActiveAlert?
        
        func deletePatient() {
    //        patient.delete() { response in
    //            switch response {
    //            case .success:
    //                let generator = UINotificationFeedbackGenerator()
    //                generator.notificationOccurred(.success)
    //                patients.patients.removeAll(where: { $0.patientID == patient.patientID })
    //                appointments.appointments.removeAll(where: { $0.patientID == patient.patientID } )
    //                presentationMode.wrappedValue.dismiss()
    //            case .failure(let error):
    //                alertMessage = error.getMessage()
    //                activeAlert = .error
    //            }
    //        }
        }
    }
}

struct PatientDeleteButton: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ViewModel
    @ObservedObject var patient: Patient
    
    
    var body: some View {
        DeleteButton(activeAlert: $viewModel.activeAlert, title: label(.deletePatient))
            .alert(item: $viewModel.activeAlert) { item in
                switch item {
                    case .warning:
                    return Alert(title: Text(label(.areYouSure_patient)), message: Text(String(format: label(.deletePatientMessage), patient.title)), primaryButton: .destructive(Text(label(.delete)), action: viewModel.deletePatient), secondaryButton: .cancel())
                case .error:
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                    return Alert(title: Text(label(.error)), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                case .settingsIssue:
                    return Alert(title: Text(label(.error)), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                }
            }
    }
}

struct PatientDeleteButton_Previews: PreviewProvider {
    static var previews: some View {
        PatientDeleteButton(viewModel: .init(), patient: Patient(using: Patient.example))
    }
}
