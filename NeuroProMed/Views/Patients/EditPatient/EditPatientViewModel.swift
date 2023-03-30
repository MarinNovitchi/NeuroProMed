//
//  EditPatientViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Combine
import Foundation
import SwiftUI

extension EditPatient {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var temporaryBiometricsSettings = false
        @Published var alertMessage = ""
        @Published var isShowingAlert = false
        
        let dismissView = CurrentValueSubject<Bool, Never>(false)
        
        func save(_ patientData: Patient.PatientProperties, to patient: Patient, showBiometrics: Bool) {
            Task {
                let generator = UINotificationFeedbackGenerator()
                do {
                    patient.updatePatient(using: patientData)
                    let response = try await patient.update()
                    guard !response.error else {
                        let error = AppError.serverError(response.message ?? "Unknown message")
                        error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                        return
                    }
                    generator.notificationOccurred(.success)
                    if showBiometrics {
                        saveBiometricsSetting(for: patient.patientID)
                    }
                    dismissView.send(true)
                } catch let error as AppError  {
                    error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                } catch {
                    let error = AppError.unknown
                    error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                }
            }
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
