//
//  FilterAppointmentsViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Combine
import Foundation
import SwiftUI

extension FilterAppointments {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var notificationSchedule = NotificationSchedule(description: NSLocalizedString("notificationNone", comment: "Notification Schedule - None"), calendarComponent: .calendar, value: -1)
        @Published var selectedCalendar = NSLocalizedString("notificationNone", comment: "Notification Schedule - None")

        @Published var alertMessage = ""
        @Published var isShowingAlert = false
        
        let isFilterApplied = CurrentValueSubject<Bool?, Never>(nil)
        
        func applyFilter(using data: Appointment.AppointmentProperties) {
            Task {
                let generator = UINotificationFeedbackGenerator()
                do {
                    appState.appointments.appointments = try await appState.appointments.filterAppointments(using: data)
                    appState.objectWillChange.send()
                    generator.notificationOccurred(.success)
                    isFilterApplied.send(true)
                } catch let error as AppError  {
                    error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                } catch {
                    let error = AppError.unknown
                    error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                }
            }
        }
        
        func removeFilter() {
            Task {
                let generator = UINotificationFeedbackGenerator()
                do {
                    appState.appointments.appointments = try await appState.appointments.load()
                    appState.objectWillChange.send()
                    generator.notificationOccurred(.success)
                    isFilterApplied.send(false)
                } catch let error as AppError  {
                    error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                } catch {
                    let error = AppError.unknown
                    error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                }
            }
        }
        
        var isUserDoctor: Bool {
            appState.isUserDoctor
        }
    }
}
