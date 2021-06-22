//
//  EditPatientView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.03.2021.
//

import SwiftUI

struct EditPatient: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var patient: Patient
    
    @Binding var patientData: Patient.PatientProperties
    @Binding var useBiometrics: Bool
    let showBiometrics: Bool
    
    @State private var temporaryBiometricsSettings = false
    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    
    func saveChanges() {
        patient.updatePatient(using: patientData)
        patient.update() { response in
            let generator = UINotificationFeedbackGenerator()
            switch response {
            case .success:
                if showBiometrics {
                    saveBiometricsSetting()
                }
                generator.notificationOccurred(.success)
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
            }
        }
    }
    
    func saveBiometricsSetting() {
        let keychainHelper = KeychainHelper()
        let credentials = KeychainCredentials(userID: patient.patientID, isDoctor: false, useBiometrics: temporaryBiometricsSettings)
        do {
            try keychainHelper.updateCredentials(credentials: credentials)
            useBiometrics = temporaryBiometricsSettings
        } catch {
            alertMessage = label(.failToUpdateSettings)
            isShowingAlert = true
        }
    }
    
    
    var body: some View {
        Form {
            PatientDetailsSection(patientData: $patientData, isUsedByFilter: false)
            if showBiometrics {
                BiometricsSettingsView(useBiometrics: $temporaryBiometricsSettings)
            }
        }
        .navigationTitle(label(.editPatient))
        .navigationBarItems(
            leading: Button(label(.cancel)) { presentationMode.wrappedValue.dismiss() },
            trailing: Button(label(.save), action: saveChanges)
                .disabled(patientData.firstName.isEmpty || patientData.lastName.isEmpty)
        )
        .onAppear(perform: { temporaryBiometricsSettings = useBiometrics })
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text(label(.error)), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct EditPatient_Previews: PreviewProvider {
    static var previews: some View {
        EditPatient(
            patient: Patient(using: Patient.example),
            patientData: .constant(Patient.example),
            useBiometrics: .constant(true), showBiometrics: true
        )
    }
}
