//
//  EditAppointment.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.04.2021.
//

import SwiftUI

struct EditAppointment: View {
    
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var appointment: Appointment
    
    @Binding var appointmentData: Appointment.AppointmentProperties
    @Binding var notificationSchedule: NotificationSchedule
    @Binding var selectedCalendar: String
    let originalDate: Date
    @ObservedObject var appState: AppState
    
    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    
    func saveChanges() {
        appointment.updateAppointment(using: appointmentData)
//        appointment.update() { response in
//            let generator = UINotificationFeedbackGenerator()
//            switch response {
//            case .success:
//                updateNotificationAndCalendar(for: appointment)
//                generator.notificationOccurred(.success)
//                presentationMode.wrappedValue.dismiss()
//            case .failure(let error):
//                error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
//            }
//        }
    }
    
    func updateNotificationAndCalendar(for appointment: Appointment) {
        guard let foundDoctor = appState.doctors.doctors.first(where: { $0.doctorID == appointment.doctorID }),
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
        
        notificationSchedule.updateNotification(appointment: appointment, message: message)
        CalendarHelper().update(selectedCalendar: selectedCalendar, on: originalDate, with: appointment, title: message)
    }
    
    var isAppointmentValid: Bool {
        appState.doctors.doctors.contains {
            $0.doctorID == appointmentData.doctorID
        } && appState.patients.patients.contains {
            $0.patientID == appointmentData.patientID
        }
    }
    
    var body: some View {
        Form {
            AppointmentFormGroup(
                appointmentData: $appointmentData,
                notificationSchedule: $notificationSchedule,
                selectedCalendar: $selectedCalendar,
                isUsedByFilter: false, appState: appState
            )
        }
            .navigationTitle(label(.editAppointment))
            .navigationBarItems(
                leading: Button(label(.cancel)) { dismiss() },
                trailing: Button(label(.save), action: saveChanges).disabled(!isAppointmentValid)
            )
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text(label(.error)), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
    }
}


struct EditAppointment_Previews: PreviewProvider {
    static var previews: some View {
        EditAppointment(
            appointment: Appointment(using: Appointment.example),
            appointmentData: .constant(Appointment.example),
            notificationSchedule: .constant(NotificationSchedule(description: NSLocalizedString("notificationNone", comment: "Notification Schedule - None"), calendarComponent: .calendar, value: -1)),
            selectedCalendar: .constant(NSLocalizedString("notificationNone", comment: "Notification Schedule - None")),
            originalDate: Date(),
            appState: .shared)
    }
}
