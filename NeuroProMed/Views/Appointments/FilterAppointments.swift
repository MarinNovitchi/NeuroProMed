//
//  FilterAppointmentsView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 10.04.2021.
//

import SwiftUI

struct FilterAppointments: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var appointments: Appointments
    @ObservedObject var doctors: Doctors
    @ObservedObject var patients: Patients
    @ObservedObject var services: Services
    
    @Binding var isFilterApplied: Bool
    @Binding var filterData: Appointment.AppointmentProperties
    let doctorUserID: UUID?
    let isUserDoctor: Bool
    
    @State private var notificationSchedule = NotificationSchedule(description: NSLocalizedString("notificationNone", comment: "Notification Schedule - None"), calendarComponent: .calendar, value: -1)
    @State private var selectedCalendar = NSLocalizedString("notificationNone", comment: "Notification Schedule - None")

    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    
    func applyFilter() {
        appointments.filterAppointments(using: filterData) { response in
            let generator = UINotificationFeedbackGenerator()
            switch response {
            case .success(let rs):
                self.appointments.appointments = rs
                isFilterApplied = true
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
            }
        }
    }
    
    func removeFilter() {
        if isUserDoctor {
            if let doctorUserID = doctorUserID {
                filterData.doctorID = doctorUserID
            }
        }
        appointments.load() { response in
            let generator = UINotificationFeedbackGenerator()
            switch response {
            case .success(let rs):
                self.appointments.appointments = rs
                isFilterApplied = false
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
            }
        }
    }
    
    var body: some View {
        Form {
            AppointmentFormGroup(
                appointments: appointments,
                doctors: doctors,
                patients: patients,
                services: services,
                appointmentData: $filterData,
                notificationSchedule: $notificationSchedule,
                selectedCalendar: $selectedCalendar,
                isUserDoctor: isUserDoctor,
                isUsedByFilter: true
            )
            if isFilterApplied {
                ListButton(title: label(.removeFilter), action: removeFilter)
            }
        }
        .navigationTitle(label(.filterAppointments))
        .navigationBarItems(
            leading: Button(label(.cancel)) { presentationMode.wrappedValue.dismiss() },
            trailing: Button(label(.filterAction), action: applyFilter)
        )
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text(label(.error)), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct FilterAppointments_Previews: PreviewProvider {
    static var previews: some View {
        FilterAppointments(
            appointments: Appointments(),
            doctors: Doctors(),
            patients: Patients(),
            services: Services(),
            isFilterApplied: .constant(false),
            filterData: .constant(Appointment.example),
            doctorUserID: nil,
            isUserDoctor: true
        )
    }
}
