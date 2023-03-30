//
//  AppointmentDeleteButtonViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Combine
import Foundation
import SwiftUI

extension AppointmentDeleteButton {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var activeAlert: ActiveAlert?
        @Published var alertMessage = ""
        
        let dismissView = CurrentValueSubject<Bool, Never>(false)
        
        func delete(appointment: Appointment) {
            Task {
                let generator = UINotificationFeedbackGenerator()
                do {
                    let response = try await appointment.delete()
                    guard !response.error else {
                        let error = AppError.serverError(response.message ?? "Unknown message")
                        error.trigger(with: generator, &activeAlert, message: &alertMessage)
                        return
                    }
                    appState.appointments.appointments.removeAll{ $0.appointmentID == appointment.appointmentID }
                    deleteNotificationAndCalendar(for: appointment)
                    generator.notificationOccurred(.success)
                    dismissView.send(true)
                } catch let error as AppError  {
                    error.trigger(with: generator, &activeAlert, message: &alertMessage)
                } catch {
                    let error = AppError.unknown
                    error.trigger(with: generator, &activeAlert, message: &alertMessage)
                }
            }
        }
        
        func deleteNotificationAndCalendar(for appointment: Appointment) {
            CalendarHelper().deleteEvent(on: appointment.appointmentDate)
            NotificationSchedule().deleteNotification(appointment: appointment)
        }
    }
}
