//
//  PatientViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Foundation

extension PatientView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        @Published var patientData: Patient.PatientProperties = Patient.PatientProperties()
        @Published var appointmentData = Appointment.AppointmentProperties()
        
        @Published var activeSheet: ActiveSheet?

        enum ActiveSheet: Identifiable {
            case editPatientSheet, createAppointmentSheet
            var id: Int {
                hashValue
            }
        }
        
        func createAppointment(for patient: Patient) {
            appointmentData.patientID = patient.patientID
            appointmentData.doctorID = AppState.shared.userID
            activeSheet = .createAppointmentSheet
        }
    }
}
