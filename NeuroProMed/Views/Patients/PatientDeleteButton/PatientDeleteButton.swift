//
//  PatientDeleteButton.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 05.04.2021.
//

import SwiftUI

struct PatientDeleteButton: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ViewModel
    @ObservedObject var patient: Patient
    @ObservedObject var appState: AppState
    
    
    var body: some View {
        DeleteButton(activeAlert: $viewModel.activeAlert, title: label(.deletePatient))
            .alert(item: $viewModel.activeAlert) { item in
                switch item {
                    case .warning:
                    return Alert(
                        title: Text(label(.areYouSure_patient)),
                        message: Text(String(format: label(.deletePatientMessage), patient.title)),
                        primaryButton: .destructive(Text(label(.delete)), action: { viewModel.delete(patient: patient) }),
                        secondaryButton: .cancel())
                case .error:
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                    return Alert(title: Text(label(.error)), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                case .settingsIssue:
                    return Alert(title: Text(label(.error)), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                }
            }
            .onReceive(viewModel.dismissView) { isDismissed in
                if isDismissed {
                    dismiss()
                }
            }
    }
}

struct PatientDeleteButton_Previews: PreviewProvider {
    static var previews: some View {
        PatientDeleteButton(viewModel: .init(), patient: Patient(using: Patient.example), appState: .shared)
    }
}
