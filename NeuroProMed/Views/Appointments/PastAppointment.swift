//
//  PastAppointment.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 04.04.2021.
//

import SwiftUI

struct PastAppointment: View {
    
    @ObservedObject var appointments: Appointments
    @ObservedObject var doctors: Doctors
    @ObservedObject var patients: Patients
    @ObservedObject var services: Services
    
    @ObservedObject var appointment: Appointment
    let isPatientPerspective: Bool
    let isUserDoctor: Bool
    
    var appointmentDoctor: Doctor {
        doctors.doctors.first(where: { $0.doctorID == appointment.doctorID }) ?? Doctor(using: Doctor.example)
    }
    var appointmentPatient: Patient {
        patients.patients.first(where: { $0.patientID == appointment.patientID }) ?? Patient(using: Patient.example)
    }
    
    var body: some View {
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
                        )) {
            PastAppointmentRow(
                services: services,
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
            appointments: Appointments(),
            doctors: Doctors(),
            patients: Patients(),
            services: Services(),
            appointment: Appointment(using: Appointment.example),
            isPatientPerspective: true,
            isUserDoctor: true
        )
    }
}

