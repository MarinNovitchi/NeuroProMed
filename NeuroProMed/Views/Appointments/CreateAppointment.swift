//
//  CreateAppointment.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 04.04.2021.
//

import SwiftUI

struct CreateAppointment: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var appointments: Appointments
    @ObservedObject var doctors: Doctors
    @ObservedObject var patients: Patients
    @ObservedObject var services: Services
    
    @Binding var appointmentData: Appointment.AppointmentProperties
    let isUserDoctor: Bool
    
    @State private var chosenDate = Date()
    @State private var chosenTime = "08:00"
    
    @State private var notificationSchedule = NotificationSchedule(description: NSLocalizedString("notificationNone", comment: "Notification Schedule - None"), calendarComponent: .calendar, value: -1)
    @State private var selectedCalendar = NSLocalizedString("notificationNone", comment: "Notification Schedule - None")
    
    @State private var alertMessage = ""
    @State private var isShowingAlert = false

    func setNotificationAndCalendar(for appointment: Appointment) {
        guard let foundDoctor = doctors.doctors.first(where: { $0.doctorID == appointment.doctorID }),
              let foundPatient = patients.patients.first(where: { $0.patientID == appointment.patientID })
        else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        let message: String
        if isUserDoctor {
            message = String(format: label(.appointmentFor), foundPatient.title, dateFormatter.string(from: appointment.appointmentDate))
        } else {
            message = String(format: label(.appointmentWith), foundDoctor.title, dateFormatter.string(from: appointment.appointmentDate))
        }
        
        notificationSchedule.setNotification(for: appointment, message: message)
        CalendarHelper().add(appointment: appointment, to: selectedCalendar, title: message)
    }
    

    func createAppointment() {
        let newAppointment = Appointment(using: appointmentData)
        newAppointment.create() { response in
            let generator = UINotificationFeedbackGenerator()
            switch response {
            case .success:
                appointments.appointments.insert(newAppointment, at: 0)
                setNotificationAndCalendar(for: newAppointment)
                generator.notificationOccurred(.success)
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
            }
        }
    }
    
    var isAppointmentValid: Bool {
        doctors.doctors.contains {
            $0.doctorID == appointmentData.doctorID
        } && patients.patients.contains {
            $0.patientID == appointmentData.patientID
        }
    }
    
    var body: some View {
        Form {
            AppointmentFormGroup(
                appointments: appointments,
                doctors: doctors,
                patients: patients,
                services: services,
                appointmentData: $appointmentData,
                notificationSchedule: $notificationSchedule,
                selectedCalendar: $selectedCalendar,
                isUserDoctor: isUserDoctor,
                isUsedByFilter: false
            )
        }
            .navigationTitle(label(.createAppointment))
            .navigationBarItems(
                leading: Button(label(.cancel)) { presentationMode.wrappedValue.dismiss() },
                trailing: Button(label(.save), action: createAppointment).disabled(!isAppointmentValid)
            )
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text(label(.error)), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }

    }
}

struct CreateAppointments_Previews: PreviewProvider {
    static var previews: some View {
        CreateAppointment(
            appointments: Appointments(),
            doctors: Doctors(),
            patients: Patients(),
            services: Services(),
            appointmentData: .constant(Appointment.example),
            isUserDoctor: true
        )
    }
}
