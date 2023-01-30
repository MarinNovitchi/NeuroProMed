//
//  AppointmentDeleteButton.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 24.04.2021.
//

import SwiftUI

struct AppointmentDeleteButton: View {
    
    @ObservedObject var appointment: Appointment
    
    @State private var activeAlert: ActiveAlert?
    @State private var alertMessage = ""
    
    func deleteAppointment() {
//        appointment.delete() { response in
//            switch response {
//            case .success:
//                let generator = UINotificationFeedbackGenerator()
//                generator.notificationOccurred(.success)
//                appointments.appointments.removeAll{ $0.appointmentID == appointment.appointmentID }
//                deleteNotificationAndCalendar()
//                presentationMode.wrappedValue.dismiss()
//            case .failure(let error):
//                alertMessage = error.getMessage()
//                activeAlert = .error
//            }
//        }
    }
    
    func deleteNotificationAndCalendar() {
        CalendarHelper().deleteEvent(on: appointment.appointmentDate)
        NotificationSchedule().deleteNotification(appointment: appointment)
    }
    
    var body: some View {
        DeleteButton(activeAlert: $activeAlert, title: label(.cancelAppointment) )
            .alert(item: $activeAlert) { item in
                switch item {
                case .warning:
                    return Alert(title: Text(label(.areYouSure_appointment)),
                                 message: Text(label(.deleteAppointmentMessage)),
                                 primaryButton: .destructive(Text(label(.delete)), action: deleteAppointment),
                                 secondaryButton: .cancel())
                case .error:
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                    return Alert(title: Text(label(.error)), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                case .settingsIssue:
                    return Alert(title: Text(label(.error)), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
    }
}

struct AppointmentDeleteButton_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentDeleteButton(appointment: Appointment(using: Appointment.example))
    }
}
