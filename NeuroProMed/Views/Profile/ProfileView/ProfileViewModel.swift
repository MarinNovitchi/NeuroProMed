//
//  ProfileViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Foundation
import SwiftUI

extension ProfileView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        var patient: Patient {
            appState.relevantPatient
        }
        @Published var patientData: Patient.PatientProperties = Patient.PatientProperties()
        
        var doctor: Doctor {
            appState.relevantDoctor
        }
        @Published var doctorData: Doctor.DoctorProperties = Doctor.DoctorProperties()
        
        @Published var alertMessage = ""
        @Published var isShowingAlert = false
        @Published var activeSheet: ActiveSheet?
        
        @Published var isHolidayListDisplayed = false {
            willSet {
                if newValue {
                    doctorData = doctor.data
                }
            }
        }
        
        func deleteKeyChainCredentials() {
            
            let generator = UINotificationFeedbackGenerator()
            let keychainHelper = KeychainHelper()
            do {
                try keychainHelper.deleteCredentials()
                generator.notificationOccurred(.success)
                AppState.shared.useBiometrics = false
                AppState.shared.isAuthenticated = false
            } catch  {
                generator.notificationOccurred(.error)
                alertMessage = label(.failToDeleteKeychain)
                isShowingAlert = true
            }
        }
        
        var isUserDoctor: Bool {
            appState.isUserDoctor
        }
        
        var hasUnavailability: Bool {
            doctor.unavailability.count > 0
        }
        
        var unavailabilityCount: Int {
            doctor.unavailability.count
        }
        
        var pageTitle: String {
            isUserDoctor ? doctor.title : patient.title
        }
        
        func edit() {
            isUserDoctor ? editDoctor() : editPatient()
        }
        
        private func editDoctor() {
            doctorData = doctor.data
            activeSheet = .editDoctorSheet
        }
        
        private func editPatient() {
            patientData = patient.data
            activeSheet = .editPatientSheet
        }
        
        enum ActiveSheet: Identifiable {
            case editPatientSheet, editDoctorSheet
            var id: Int {
                hashValue
            }
        }
    }
}
