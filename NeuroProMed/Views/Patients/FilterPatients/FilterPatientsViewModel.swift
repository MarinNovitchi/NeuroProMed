//
//  FilterPatientsViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Combine
import Foundation
import SwiftUI

extension FilterPatients {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var filterData = Patient.PatientProperties()
        
        @Published var alertMessage = ""
        @Published var isShowingAlert = false
        
        let isFilterApplied = CurrentValueSubject<Bool?, Never>(nil)
        
        func applyFilter() {
            Task {
                let generator = UINotificationFeedbackGenerator()
                do {
                    appState.patients.patients = try await appState.patients.filterPatients(using: filterData)
                    generator.notificationOccurred(.success)
                    isFilterApplied.send(true)
                } catch let error as AppError  {
                    error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                } catch {
                    let error = AppError.unknown
                    error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                }
            }
        }
        
        func removeFilter() {
            Task {
                let generator = UINotificationFeedbackGenerator()
                do {
                    appState.patients.patients = try await appState.patients.load()
                    generator.notificationOccurred(.success)
                    isFilterApplied.send(false)
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
