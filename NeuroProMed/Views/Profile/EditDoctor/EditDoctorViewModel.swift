//
//  EditDoctorViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Combine
import Foundation
import SwiftUI

extension EditDoctor {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var isAddHolidaySheetPresented = false
        @Published var temporaryBiometricsSettings = false
        
        @Published var alertMessage = ""
        @Published var isShowingAlert = false
        
        let dismissView = CurrentValueSubject<Bool, Never>(false)
        
        func saveChanges(from doctoData: Doctor.DoctorProperties, to doctor: Doctor) {
            Task {
                let generator = UINotificationFeedbackGenerator()
                do {
                    doctor.updateDoctor(using: doctoData)
                    let response = try await doctor.update()
                    guard !response.error else {
                        let error = AppError.serverError(response.message ?? "Unknown message")
                        error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                        return
                    }
                    generator.notificationOccurred(.success)
                    saveBiometricsSetting(for: doctor.doctorID)
                    dismissView.send(true)
                } catch let error as AppError  {
                    error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                } catch {
                    let error = AppError.unknown
                    error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                }
            }
        }
        
        func saveBiometricsSetting(for doctorID: UUID) {
            let keychainHelper = KeychainHelper()
            let credentials = KeychainCredentials(userID: doctorID, isDoctor: true, useBiometrics: temporaryBiometricsSettings)
            do {
                //try keychainHelper.updateCredentials(credentials: credentials)
                AppState.shared.useBiometrics = temporaryBiometricsSettings
            } catch {
                alertMessage = label(.failToUpdateSettings)
                isShowingAlert = true
            }
        }
        
        func assignBiometricsSettings() {
            temporaryBiometricsSettings = appState.useBiometrics
        }
    }
}
