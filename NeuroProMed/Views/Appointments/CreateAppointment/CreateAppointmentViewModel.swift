//
//  CreateAppointmentViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Combine
import Foundation
import SwiftUI

extension CreateAppointment {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var chosenDate = Date()
        @Published var chosenTime = "08:00"
        
        @Published var notificationSchedule = NotificationSchedule(description: NSLocalizedString("notificationNone", comment: "Notification Schedule - None"), calendarComponent: .calendar, value: -1)
        @Published var selectedCalendar = NSLocalizedString("notificationNone", comment: "Notification Schedule - None")
        
        @Published var alertMessage = ""
        @Published var isShowingAlert = false
        
        let dismissView = CurrentValueSubject<Bool, Never>(false)

        func setNotificationAndCalendar(for appointment: Appointment) {
            guard
                let foundDoctor = appState.doctors.doctors.first(where: { $0.doctorID == appointment.doctorID }),
                let foundPatient = appState.patients.patients.first(where: { $0.patientID == appointment.patientID })
            else { return }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            let message: String
            if appState.isUserDoctor {
                message = String(format: label(.appointmentFor), foundPatient.title, dateFormatter.string(from: appointment.appointmentDate))
            } else {
                message = String(format: label(.appointmentWith), foundDoctor.title, dateFormatter.string(from: appointment.appointmentDate))
            }
            
            notificationSchedule.setNotification(for: appointment, message: message)
            CalendarHelper().add(appointment: appointment, to: selectedCalendar, title: message)
        }
        
        func checkForConflict(appointment: Appointment) -> Result<Void, AppError> {
            let concurrentAppointments = appState.appointments.appointments.filter({ $0.appointmentDate == appointment.appointmentDate })
            if let concurrentPatientAppointment = concurrentAppointments.first(where: { $0.patientID == appointment.patientID }) {
                return .failure(AppError.conflictingAppointment("Cannot schedule appointment: It has a conflict with another appointment at the same time."))
            }
            if let concurrentDoctorAppointment = concurrentAppointments.first(where: { $0.doctorID == appointment.doctorID }) {
                return .failure(AppError.conflictingAppointment("Cannot schedule appointment: It has a conflict with another appointment at the same time."))
            }
            return .success(Void())
        }

        func createAppointment(using data: Appointment.AppointmentProperties) {
            Task {
                let generator = UINotificationFeedbackGenerator()
                let newAppointment = Appointment(using: data)
                if case .failure(let error) = checkForConflict(appointment: newAppointment) {
                    error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                    return
                }
                do {
                    let response = try await newAppointment.create()
                    guard !response.error else {
                        let error = AppError.serverError(response.message ?? "Unknown message")
                        error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                        return
                    }
                    appState.appointments.appointments.insert(newAppointment, at: 0)
                    setNotificationAndCalendar(for: newAppointment)
                    generator.notificationOccurred(.success)
                    appState.objectWillChange.send()
                    dismissView.send(true)
                } catch let error as AppError  {
                    error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                } catch {
                    let error = AppError.unknown
                    error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
                }
            }
        }
        
        func isAppointmentValid(_ appointmentData: Appointment.AppointmentProperties) -> Bool {
            appState.doctors.doctors.contains {
                $0.doctorID == appointmentData.doctorID
            } && appState.patients.patients.contains {
                $0.patientID == appointmentData.patientID
            }
        }
    }
}
