//
//  CreateAppointment.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 04.04.2021.
//

import SwiftUI

extension CreateAppointment {
    
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
        

        func createAppointment() {
//            let newAppointment = Appointment(using: appointmentData)
//        newAppointment.create() { response in
//            let generator = UINotificationFeedbackGenerator()
//            switch response {
//            case .success:
//                appointments.appointments.insert(newAppointment, at: 0)
//                setNotificationAndCalendar(for: newAppointment)
//                generator.notificationOccurred(.success)
//                presentationMode.wrappedValue.dismiss()
//            case .failure(let error):
//                error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
//            }
//        }
        }
        
        func isAppointmentValid(_ doctorID: UUID?) -> Bool {
            appState.doctors.doctors.contains {
                $0.doctorID == doctorID
            } && appState.patients.patients.contains {
                $0.patientID == doctorID
            }
        }
    }
}

struct CreateAppointment: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ViewModel
    @ObservedObject var appState: AppState
    @Binding var appointmentData: Appointment.AppointmentProperties
    
    var body: some View {
        Form {
            AppointmentFormGroup(
                appointmentData: $appointmentData,
                notificationSchedule: $viewModel.notificationSchedule,
                selectedCalendar: $viewModel.selectedCalendar,
                isUsedByFilter: false,
                appState: appState
            )
        }
        .navigationTitle(label(.createAppointment))
        .navigationBarItems(
            leading: Button(label(.cancel)) { dismiss() },
            trailing: Button(label(.save), action: viewModel.createAppointment).disabled(!viewModel.isAppointmentValid(appointmentData.doctorID))
        )
        .alert(isPresented: $viewModel.isShowingAlert) {
            Alert(title: Text(label(.error)), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }

    }
}

struct CreateAppointments_Previews: PreviewProvider {
    static var previews: some View {
        CreateAppointment(
            viewModel: .init(),
            appState: .shared,
            appointmentData: .constant(Appointment.example))
    }
}
