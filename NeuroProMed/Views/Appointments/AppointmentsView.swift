//
//  AppointmentsView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2021.
//

import SwiftUI

struct AppointmentsView: View {
    
    @ObservedObject var appointments: Appointments
    @ObservedObject var doctors: Doctors
    @ObservedObject var patients: Patients
    @ObservedObject var services: Services
    
    @Binding var userID: UUID
    let isUserDoctor: Bool
    
    @State var isFilterApplied = false
    @State private var appointmentData = Appointment.AppointmentProperties(doctorID: UUID(), patientID: UUID())
    
    @State var activeSheet: ActiveSheet?
    enum ActiveSheet: Identifiable {
        case createAppointmentSheet, filterAppointmentsSheet
        var id: Int {
            hashValue
        }
    }
    
    func resetAppointmentData() {
        appointmentData = isUserDoctor ?
            Appointment.AppointmentProperties(doctorID: userID, patientID: patients.patients.first?.patientID ?? UUID())
            : Appointment.AppointmentProperties(doctorID: doctors.doctors.first?.doctorID ?? UUID(), patientID: userID)
    }

    var body: some View {
        NavigationView {
            List {
                AppointmentSections(
                    appointments: appointments,
                    doctors: doctors, patients: patients,
                    services: services,
                    userID: $userID, isUserDoctor: isUserDoctor,
                    isPatientPerspective: !isUserDoctor,
                    showSorting: true,
                    useTracking: true
                )
            }
            .navigationTitle(label(.appointments))
            .navigationBarItems(
                leading: Button(label(.new)) {
                    resetAppointmentData()
                    activeSheet = .createAppointmentSheet
                },
                trailing: Button(label(.filter)) {
                    resetAppointmentData()
                    activeSheet = .filterAppointmentsSheet
                }
                    .foregroundColor(isFilterApplied ? Color("ComplimentaryColor") : .accentColor)
            )
            .fullScreenCover(item: $activeSheet) { item in
                NavigationView {
                    switch item {
                    case .createAppointmentSheet:
                        CreateAppointment(
                            appointments: appointments,
                            doctors: doctors,
                            patients: patients,
                            services: services,
                            appointmentData: $appointmentData,
                            isUserDoctor: isUserDoctor
                        )
                    case .filterAppointmentsSheet:
                        FilterAppointments(
                            appointments: appointments,
                            doctors: doctors,
                            patients: patients,
                            services: services,
                            isFilterApplied: $isFilterApplied,
                            filterData: $appointmentData,
                            doctorUserID: userID,
                            isUserDoctor: isUserDoctor
                        )
                    }
                }
            }
        }
    }
}


struct AppointmentsView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentsView(
            appointments: Appointments(),
            doctors: Doctors(),
            patients: Patients(),
            services: Services(),
            userID: .constant(UUID()), isUserDoctor: true
        )
    }
}
