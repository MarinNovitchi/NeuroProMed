//
//  AppointmentView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 21.03.2021.
//

import SwiftUI

extension AppointmentView {
    
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var isServicesExpanded = true
        @Published var appointmentData = Appointment.AppointmentProperties()
        @Published var notificationSchedule = NotificationSchedule(description: NSLocalizedString("notificationNone", comment: "Notification Schedule - None"), calendarComponent: .calendar, value: -1)
        @Published var selectedCalendar = NSLocalizedString("notificationNone", comment: "Notification Schedule - None")
        @Published var isEditSheetPresented = false
        
        func isValidForEdit(appointment: Appointment) -> Bool {
            appState.isUserDoctor || appointment.appointmentDate.compare(Date()) == .orderedDescending
        }
        
        func filteredServices(for appointment: Appointment) -> [Service] {
            appState.services.services.filter({ appointment.services.contains($0.serviceID) })
        }
        
        func isNotificationDisplayed(for appointment: Appointment) -> Bool {
            appointment.appointmentDate.compare(Date()) == .orderedDescending && notificationSchedule.value > 0
        }
        var isCalendarDisplayed: Bool {
            selectedCalendar != NSLocalizedString("notificationNone", comment: "Notification Schedule - None")
        }
        
        func loadView(for appointment: Appointment) {
            if let data = UserDefaults.standard.data(forKey: appointment.appointmentID.uuidString) {
                if let decodedSchedule = try? JSONDecoder().decode(NotificationSchedule.self, from: data) {
                    notificationSchedule = decodedSchedule
                }
            }
            if let unwrappedCalendar = CalendarHelper().getCalendar(for: appointment.appointmentDate) {
                selectedCalendar = unwrappedCalendar
            }
        }
    }
}

struct AppointmentView: View {
    
    @StateObject var viewModel: ViewModel
    @ObservedObject var appointment: Appointment
    @ObservedObject var doctor: Doctor
    @ObservedObject var patient: Patient
    @ObservedObject var appState: AppState
    
    var body: some View {
        List {
            CustomSection(header: Text(label(.appointmentDetails))) {
                AppointmentDetail(prefix: Text(label(.for_prefix)), detail: Text(patient.title))
                AppointmentDetail(prefix: Text(label(.with_prefix)), detail: Text(doctor.title))
                AppointmentDetail(prefix: Text(label(.on_prefix)), detail: Text(appointment.appointmentDate, style: .date))
                AppointmentDetail(prefix: Text(label(.at_prefix)), detail: Text(appointment.appointmentDate, style: .time))
            }
            if viewModel.filteredServices(for: appointment).count > 0 {
                CustomSection(header: Text(label(.serviceBill))) {
                    DisclosureGroup(String(format: label(.totalAmount), viewModel.filteredServices(for: appointment).reduce(0, { $0 + $1.price })), isExpanded: $viewModel.isServicesExpanded) {
                        ForEach(viewModel.filteredServices(for: appointment)) { service in
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
            if viewModel.isNotificationDisplayed(for: appointment) || viewModel.isCalendarDisplayed {
                CustomSection(header: Text(label(.notificationAndCalendar))) {
                    if viewModel.isNotificationDisplayed(for: appointment) {
                        Text(String(format: label(.alertSetToX), viewModel.notificationSchedule.description))
                    }
                    if viewModel.isCalendarDisplayed {
                        Text(String(format: label(.appointmentSavedToCalendarName), viewModel.selectedCalendar))
                    }
                }
            }
            if viewModel.isValidForEdit(appointment: appointment) {
                AppointmentDeleteButton(appointment: appointment)
            }
        }
        .navigationTitle(label(.appointment))
        .navigationBarItems(trailing: viewModel.isValidForEdit(appointment: appointment) ? Button(label(.edit)) {
            viewModel.appointmentData = appointment.data
            viewModel.isEditSheetPresented = true
            } : nil)
        .fullScreenCover(isPresented: $viewModel.isEditSheetPresented) {
            NavigationView {
                EditAppointment(
                    appointment: appointment,
                    appointmentData: $viewModel.appointmentData,
                    notificationSchedule: $viewModel.notificationSchedule,
                    selectedCalendar: $viewModel.selectedCalendar,
                    originalDate: appointment.appointmentDate,
                    appState: appState
                )
            }
            
        }
        .onAppear {
            viewModel.loadView(for: appointment)
        }
    }
}

struct AppointmentView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentView(
            viewModel: .init(),
            appointment: Appointment(using: Appointment.example),
            doctor: Doctor(using: Doctor.example),
            patient: Patient(using: Patient.example),
            appState: .shared)
    }
}
