//
//  CreatePatientViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Combine
import Foundation
import SwiftUI

extension CreatePatient {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var patientData = Patient.PatientProperties()
        
        @Published var alertMessage = ""
        @Published var isShowingAlert = false
        
        let dismissView = CurrentValueSubject<Bool, Never>(false)

        func createPatient() {
            Task {
                let generator = UINotificationFeedbackGenerator()
                let newPatient = Patient(using: patientData)
                do {
                    let response = try await newPatient.create()
                    guard !response.error else {
                        let error = AppError.serverError(response.message ?? "Unknown message")
                        error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                        return
                    }
                    appState.patients.patients.insert(newPatient, at: 0)
                    generator.notificationOccurred(.success)
                    dismissView.send(true)
                } catch let error as AppError  {
                    error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                } catch {
                    let error = AppError.unknown
                    error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                }
            }
        }
        
    }
}
