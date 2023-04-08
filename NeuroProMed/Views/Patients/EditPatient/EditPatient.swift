//
//  EditPatientView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.03.2021.
//

import SwiftUI

struct EditPatient: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ViewModel
    @ObservedObject var patient: Patient
    @ObservedObject var appState: AppState
    
    @Binding var patientData: Patient.PatientProperties
    let showExtraSettings: Bool
    
    var body: some View {
        Form {
            PatientDetailsSection(patientData: $patientData, isUsedByFilter: false)
            if showExtraSettings {
                BiometricsSettingsView(useBiometrics: $viewModel.temporaryBiometricsSettings)
                PatientDeleteButton(viewModel: .init(), patient: patient, appState: appState)
            }
        }
        .navigationTitle(label(.editPatient))
        .navigationBarItems(
            leading: Button(label(.cancel)) { dismiss() },
            trailing: Button(label(.save)) { viewModel.save(patientData, to: patient, showBiometrics: showExtraSettings) }
                .disabled(patientData.firstName.isEmpty || patientData.lastName.isEmpty)
        )
        .onReceive(viewModel.dismissView) { isDismissed in
            if isDismissed {
                dismiss()
            }
        }
        .onAppear { viewModel.assignTemporaryBiometricsSettings() }
        .alert(isPresented: $viewModel.isShowingAlert) {
            Alert(title: Text(label(.error)), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct EditPatient_Previews: PreviewProvider {
    static var previews: some View {
        EditPatient(
            viewModel: .init(),
            patient: Patient(using: Patient.example),
            appState: .shared,
            patientData: .constant(Patient.example),
            showExtraSettings: true
        )
    }
}
