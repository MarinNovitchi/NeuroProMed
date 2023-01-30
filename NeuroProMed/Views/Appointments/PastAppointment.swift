//
//  PastAppointment.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 04.04.2021.
//

import SwiftUI

struct PastAppointment: View {
    
    @ObservedObject var appointment: Appointment
    @ObservedObject var appState: AppState
    let isPatientPerspective: Bool
    
    var appointmentDoctor: Doctor {
        appState.doctors.doctors.first(where: { $0.doctorID == appointment.doctorID }) ?? Doctor(using: Doctor.example)
    }
    var appointmentPatient: Patient {
        appState.patients.patients.first(where: { $0.patientID == appointment.patientID }) ?? Patient(using: Patient.example)
    }
    
    var body: some View {
        NavigationLink(destination:
                        AppointmentView(
                            viewModel: .init(),
                            appointment: appointment,
                            doctor: appointmentDoctor,
                            patient: appointmentPatient,
                            appState: appState
                        )) {
            PastAppointmentRow(
                appState: appState,
                appointment: appointment,
                doctor: appointmentDoctor,
                patient: appointmentPatient,
                isPatientPerspective: isPatientPerspective)
        }
    }
}

struct PastAppointment_Previews: PreviewProvider {
    static var previews: some View {
        PastAppointment(
            appointment: Appointment(using: Appointment.example),
            appState: .shared,
            isPatientPerspective: true
        )
    }
}

