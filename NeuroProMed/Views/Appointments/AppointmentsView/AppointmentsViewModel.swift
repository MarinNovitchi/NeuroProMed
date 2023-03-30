//
//  AppointmentsViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Foundation

extension AppointmentsView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var isFilterApplied = false
        @Published var appointmentData = Appointment.AppointmentProperties(doctorID: UUID(), patientID: UUID())
        
        @Published var activeSheet: ActiveSheet?
        enum ActiveSheet: Identifiable {
            case createAppointmentSheet, filterAppointmentsSheet
            var id: Int {
                hashValue
            }
        }
        
        func triggerAppointmentCreation() {
            resetAppointmentData()
            activeSheet = .createAppointmentSheet
        }
        
        func triggerAppointmentFiltering() {
            resetAppointmentData()
            activeSheet = .filterAppointmentsSheet
        }
        
        func resetAppointmentData() {
            appointmentData = appState.isUserDoctor ?
            Appointment.AppointmentProperties(
                doctorID: appState.userID,
                patientID: appState.patients.patients.first?.patientID ?? UUID())
            : Appointment.AppointmentProperties(
                doctorID: appState.doctors.doctors.first?.doctorID ?? UUID(),
                patientID: appState.userID)
        }
        
        var isUserDoctor: Bool {
            appState.isUserDoctor
        }
    }
}
