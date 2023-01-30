//
//  EditPatientView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.03.2021.
//

import SwiftUI

extension EditPatient {
    
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var temporaryBiometricsSettings = false
        @Published var alertMessage = ""
        @Published var isShowingAlert = false
        
        func saveChanges() {
//            patient.updatePatient(using: patientData)
    //        patient.update() { response in
    //            let generator = UINotificationFeedbackGenerator()
    //            switch response {
    //            case .success:
    //                if showBiometrics {
    //                    saveBiometricsSetting()
    //                }
    //                generator.notificationOccurred(.success)
    //                presentationMode.wrappedValue.dismiss()
    //            case .failure(let error):
    //                error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
    //            }
    //        }
        }
        
        func saveBiometricsSetting(for patientID: UUID) {
            let keychainHelper = KeychainHelper()
            let credentials = KeychainCredentials(userID: patientID, isDoctor: false, useBiometrics: temporaryBiometricsSettings)
            do {
                try keychainHelper.updateCredentials(credentials: credentials)
                appState.useBiometrics = temporaryBiometricsSettings
            } catch {
                alertMessage = label(.failToUpdateSettings)
                isShowingAlert = true
            }
        }
        
        func assignTemporaryBiometricsSettings() {
            temporaryBiometricsSettings = appState.useBiometrics
        }
    }
}

struct EditPatient: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ViewModel
    @ObservedObject var patient: Patient
    @ObservedObject var appState: AppState
    
    @Binding var patientData: Patient.PatientProperties
    let showBiometrics: Bool
    
    var body: some View {
        Form {
            PatientDetailsSection(patientData: $patientData, isUsedByFilter: false)
            if showBiometrics {
                BiometricsSettingsView(useBiometrics: $viewModel.temporaryBiometricsSettings)
            }
        }
        .navigationTitle(label(.editPatient))
        .navigationBarItems(
            leading: Button(label(.cancel)) { dismiss() },
            trailing: Button(label(.save), action: viewModel.saveChanges)
                .disabled(patientData.firstName.isEmpty || patientData.lastName.isEmpty)
        )
        .onAppear(perform: viewModel.assignTemporaryBiometricsSettings)
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
            showBiometrics: true
        )
    }
}
