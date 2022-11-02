//
//  PatientView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.03.2021.
//

import SwiftUI

struct PatientView: View {
    
    @ObservedObject var appointments: Appointments
    @ObservedObject var doctors: Doctors
    @ObservedObject var patients: Patients
    @ObservedObject var services: Services
    
    @ObservedObject var patient: Patient
    
    @Binding var userID: UUID
    
    let isUserDoctor: Bool
    
    
    @State private var patientData: Patient.PatientProperties = Patient.PatientProperties()
    @State private var appointmentData = Appointment.AppointmentProperties()
    
    @State var activeSheet: ActiveSheet?

    enum ActiveSheet: Identifiable {
        case editPatientSheet, createAppointmentSheet
        var id: Int {
            hashValue
        }
    }
    
    func createAppointment() {
        appointmentData.patientID = patient.patientID
        appointmentData.doctorID = userID
        activeSheet = .createAppointmentSheet
    }
    
    
    var body: some View {
        List {
            PatientDetails(patient: patient)
            ListButton(title: label(.createAppointment), action: createAppointment)
            AppointmentSections(
                appointments: appointments,
                doctors: doctors,
                patients: patients,
                services: services,
                userID: Binding<UUID>( get: { patient.patientID }, set: { newValue in }),
                isUserDoctor: isUserDoctor,
                isPatientPerspective: true,//patient.patientID,
                showSorting: false,
                useTracking: false
            )
            PatientDeleteButton(appointments: appointments, patients: patients, patient: patient)
        }
        .navigationBarTitle(Text(patient.title), displayMode: .inline)
        .navigationBarItems(trailing:
                Button(label(.edit)) {
                patientData = patient.data
                activeSheet = .editPatientSheet
            })
        .fullScreenCover(item: $activeSheet) { item in
            NavigationView {
                switch item {
                case .editPatientSheet:
                    EditPatient(
                        patient: patient,
                        patientData: $patientData,
                        useBiometrics: .constant(false), showBiometrics: false
                    )
                case .createAppointmentSheet:
                    CreateAppointment(
                        appointments: appointments,
                        doctors: doctors,
                        patients: patients,
                        services: services,
                        appointmentData: $appointmentData,
                        isUserDoctor: isUserDoctor
                    )
                }
            }
        }
    }
}

struct PatientView_Previews: PreviewProvider {
    
    static var previews: some View {
        PatientView(
            appointments: Appointments(),
            doctors: Doctors(),
            patients: Patients(),
            services: Services(),
            patient: Patient(using: Patient.example),
            userID: .constant(UUID()), isUserDoctor: true
        )
    }
}
