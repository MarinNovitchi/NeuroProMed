//
//  UpcomingAppointment.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 04.04.2021.
//

import SwiftUI

struct UpcomingAppointment: View {
    
    @ObservedObject var appState = AppState.shared
    
    @ObservedObject var appointments: Appointments
    @ObservedObject var doctors: Doctors
    @ObservedObject var patients: Patients
    @ObservedObject var services: Services
    
    @ObservedObject var appointment: Appointment
    let isPatientPerspective: Bool
    let isUserDoctor: Bool
    let useTracking: Bool
    
    var pushNavigationBinding : Binding<String?> {
        .init { () -> String? in
            appState.selectedAppointmentID
        } set: { (newValue) in
            appState.selectedAppointmentID = newValue
        }
    }
    
    var appointmentDoctor: Doctor {
        doctors.doctors.first(where: { $0.doctorID == appointment.doctorID }) ?? Doctor(using: Doctor.example)
    }
    var appointmentPatient: Patient {
        patients.patients.first(where: { $0.patientID == appointment.patientID }) ?? Patient(using: Patient.example)
    }
    
    var body: some View {
        if useTracking {
            NavigationLink(destination:
                            AppointmentView(
                                appointments: appointments,
                                doctors: doctors,
                                patients: patients,
                                services: services,
                                appointment: appointment,
                                doctor: appointmentDoctor,
                                patient: appointmentPatient,
                                isUserDoctor: isUserDoctor
                            ),
                           tag: appointment.appointmentID.uuidString,
                           selection: pushNavigationBinding
            ) {
                UpcomingAppointmentRow(
                    appointments: appointments,
                    doctors: doctors,
                    patients: patients,
                    services: services,
                    appointment: appointment,
                    doctor: appointmentDoctor,
                    patient: appointmentPatient,
                    isPatientPerspective: isPatientPerspective
                )
            }
        } else {
            NavigationLink(destination:
                            AppointmentView(
                                appointments: appointments,
                                doctors: doctors,
                                patients: patients,
                                services: services,
                                appointment: appointment,
                                doctor: appointmentDoctor,
                                patient: appointmentPatient,
                                isUserDoctor: isUserDoctor
                            )
            ) {
                UpcomingAppointmentRow(
                    appointments: appointments,
                    doctors: doctors,
                    patients: patients,
                    services: services,
                    appointment: appointment,
                    doctor: appointmentDoctor,
                    patient: appointmentPatient,
                    isPatientPerspective: isPatientPerspective
                )
            }
        }

    }
}

struct UpcomingAppointment_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingAppointment(
            appointments: Appointments(),
            doctors: Doctors(),
            patients: Patients(),
            services: Services(),
            appointment: Appointment(using: Appointment.example),
            isPatientPerspective: true,
            isUserDoctor: true,
            useTracking: false
        )
    }
}
