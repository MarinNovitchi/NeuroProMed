//
//  PatientDeleteButtonViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Combine
import Foundation
import SwiftUI

extension PatientDeleteButton {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var alertMessage = ""
        @Published var activeAlert: ActiveAlert?
        
        let dismissView = CurrentValueSubject<Bool, Never>(false)
        
        func delete(patient: Patient) {
            Task {
                let generator = UINotificationFeedbackGenerator()
                do {
                    let response = try await patient.delete()
                    guard !response.error else {
                        let error = AppError.serverError(response.message ?? "Unknown message")
                        error.trigger(with: generator, &activeAlert, message: &alertMessage)
                        return
                    }
                    appState.patients.patients.removeAll { $0.patientID == patient.patientID }
                    appState.appointments.appointments.removeAll { $0.patientID == patient.patientID }
                    appState.objectWillChange.send()
                    generator.notificationOccurred(.success)
                    dismissView.send(true)
                } catch let error as AppError  {
                    error.trigger(with: generator, &activeAlert, message: &alertMessage)
                } catch {
                    let error = AppError.unknown
                    error.trigger(with: generator, &activeAlert, message: &alertMessage)
                }
            }
        }
    }
}
