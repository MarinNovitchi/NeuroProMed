//
//  AppointmentViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Foundation

extension AppointmentView {
    
    @MainActor
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
        
        func filteredServices(for appointment: Appointment) -> [AppointmentService] {
            appointment.appointmentServices
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
