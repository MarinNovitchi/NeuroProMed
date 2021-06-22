//
//  AppointmentView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 21.03.2021.
//

import SwiftUI

struct AppointmentView: View {
    
    @ObservedObject var appointments: Appointments
    @ObservedObject var doctors: Doctors
    @ObservedObject var patients: Patients
    @ObservedObject var services: Services
    
    @ObservedObject var appointment: Appointment
    @ObservedObject var doctor: Doctor
    @ObservedObject var patient: Patient
    
    let isUserDoctor: Bool
    
    @State private var isServicesExpanded = true
    @State private var appointmentData = Appointment.AppointmentProperties()
    @State private var notificationSchedule = NotificationSchedule(description: NSLocalizedString("notificationNone", comment: "Notification Schedule - None"), calendarComponent: .calendar, value: -1)
    @State private var selectedCalendar = NSLocalizedString("notificationNone", comment: "Notification Schedule - None")
    @State private var isEditSheetPresented = false
    
    var isValidForEdit: Bool {
        isUserDoctor || appointment.appointmentDate.compare(Date()) == .orderedDescending
    }
    
    var filteredServices: [Service] {
        services.services.filter({ appointment.services.contains($0.serviceID) })
    }
    
    var isNotificationDisplayed: Bool {
        appointment.appointmentDate.compare(Date()) == .orderedDescending && notificationSchedule.value > 0
    }
    var isCalendarDisplayed: Bool {
        selectedCalendar != NSLocalizedString("notificationNone", comment: "Notification Schedule - None")
    }
    
    func loadView() {
        if let data = UserDefaults.standard.data(forKey: appointment.appointmentID.uuidString) {
            if let decodedSchedule = try? JSONDecoder().decode(NotificationSchedule.self, from: data) {
                notificationSchedule = decodedSchedule
            }
        }
        if let unwrappedCalendar = CalendarHelper().getCalendar(for: appointment.appointmentDate) {
            selectedCalendar = unwrappedCalendar
        }
    }
    
    var body: some View {
        List {
            CustomSection(header: Text(label(.appointmentDetails))) {
                AppointmentDetail(prefix: Text(label(.for_prefix)), detail: Text(patient.title))
                AppointmentDetail(prefix: Text(label(.with_prefix)), detail: Text(doctor.title))
                AppointmentDetail(prefix: Text(label(.on_prefix)), detail: Text(appointment.appointmentDate, style: .date))
                AppointmentDetail(prefix: Text(label(.at_prefix)), detail: Text(appointment.appointmentDate, style: .time))
            }
            if let investigation = appointment.investigation {
                CustomSection(header: Text(label(.investigation))) {
                    Text(investigation)
                }
            }
            if let diagnosis = appointment.diagnosis {
                CustomSection(header: Text(label(.diagnosis))) {
                    Text(diagnosis)
                }
            }
            if filteredServices.count > 0 {
                CustomSection(header: Text(label(.serviceBill))) {
                    DisclosureGroup(String(format: label(.totalAmount), filteredServices.reduce(0, { $0 + $1.price })), isExpanded: $isServicesExpanded) {
                        ForEach(filteredServices) { service in
                            HStack {
                                Text(service.name)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(service.price) lei")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            if isNotificationDisplayed || isCalendarDisplayed {
                CustomSection(header: Text(label(.notificationAndCalendar))) {
                    if isNotificationDisplayed {
                        Text(String(format: label(.alertSetToX), notificationSchedule.description))
                    }
                    if isCalendarDisplayed {
                        Text(String(format: label(.appointmentSavedToCalendarName), selectedCalendar))
                    }
                }
            }
            if isValidForEdit {
                AppointmentDeleteButton(appointments: appointments, appointment: appointment)
            }
        }
        .navigationTitle(label(.appointment))
        .navigationBarItems(trailing: isValidForEdit ? Button(label(.edit)) {
            appointmentData = appointment.data
            isEditSheetPresented = true
            } : nil)
        .fullScreenCover(isPresented: $isEditSheetPresented) {
            NavigationView {
                EditAppointment(
                    appointments: appointments,
                    doctors: doctors,
                    patients: patients,
                    services: services,
                    appointment: appointment,
                    appointmentData: $appointmentData,
                    notificationSchedule: $notificationSchedule,
                    selectedCalendar: $selectedCalendar,
                    originalDate: appointment.appointmentDate,
                    isUserDoctor: isUserDoctor
                )
            }
            
        }
        .onAppear(perform: loadView)
    }
}

struct AppointmentView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentView(
            appointments: Appointments(),
            doctors: Doctors(),
            patients: Patients(),
            services: Services(),
            appointment: Appointment(using: Appointment.example),
            doctor: Doctor(using: Doctor.example),
            patient: Patient(using: Patient.example),
            isUserDoctor: true)
    }
}
