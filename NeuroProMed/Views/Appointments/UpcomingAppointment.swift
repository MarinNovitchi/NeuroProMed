//
//  UpcomingAppointment.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 04.04.2021.
//

import SwiftUI

struct UpcomingAppointment: View {
    
    @ObservedObject var appState: AppState
    
    @ObservedObject var appointment: Appointment
    let isPatientPerspective: Bool
    let useTracking: Bool
    
    var pushNavigationBinding : Binding<String?> {
        .init { () -> String? in
            appState.selectedAppointmentID
        } set: { (newValue) in
            appState.selectedAppointmentID = newValue
        }
    }
    
    var appointmentDoctor: Doctor {
        appState.doctors.doctors.first(where: { $0.doctorID == appointment.doctorID }) ?? Doctor(using: Doctor.example)
    }
    var appointmentPatient: Patient {
        appState.patients.patients.first(where: { $0.patientID == appointment.patientID }) ?? Patient(using: Patient.example)
    }
    
    var body: some View {
        if useTracking {
            NavigationLink(destination:
                            AppointmentView(
                                viewModel: .init(),
                                appointment: appointment,
                                doctor: appointmentDoctor,
                                patient: appointmentPatient,
                                appState: appState
                            ),
                           tag: appointment.appointmentID.uuidString,
                           selection: pushNavigationBinding
            ) {
                UpcomingAppointmentRow(
                    viewModel: .init(),
                    appointment: appointment,
                    doctor: appointmentDoctor,
                    patient: appointmentPatient,
                    appState: appState,
                    isPatientPerspective: isPatientPerspective
                )
            }
        } else {
            NavigationLink(destination:
                            AppointmentView(
                                viewModel: .init(),
                                appointment: appointment,
                                doctor: appointmentDoctor,
                                patient: appointmentPatient,
                                appState: appState
                            )
            ) {
                UpcomingAppointmentRow(
                    viewModel: .init(),
                    appointment: appointment,
                    doctor: appointmentDoctor,
                    patient: appointmentPatient,
                    appState: appState,
                    isPatientPerspective: isPatientPerspective
                )
            }
        }

    }
}

struct UpcomingAppointment_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingAppointment(
            appState: .shared,
            appointment: Appointment(using: Appointment.example),
            isPatientPerspective: true,
            useTracking: false
        )
    }
}
