//
//  AppointmentFormGroup.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.04.2021.
//

import SwiftUI


struct AppointmentFormGroup: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var appointments: Appointments
    @ObservedObject var doctors: Doctors
    @ObservedObject var patients: Patients
    @ObservedObject var services: Services
    
    @Binding var appointmentData: Appointment.AppointmentProperties
    @Binding var notificationSchedule: NotificationSchedule
    @Binding var selectedCalendar: String
    let isUserDoctor: Bool
    let isUsedByFilter: Bool
    
    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    
    func doctorPickerSet(newValue: UUID) {
        if appointments.appointments.contains(where: { app in
            app.appointmentDate == appointmentData.appointmentDate && app.doctorID == appointmentData.doctorID
        }) {
            appointmentData.appointmentDate = nil
        }
        appointmentData.doctorID = newValue
    }

    var body: some View {
        Group {
            CustomSection(header: Text(label(.appointmentDetails))){
                if isUserDoctor {
                    Picker(selection: Binding<UUID>(
                        get: { appointmentData.patientID ?? UUID() },
                        set: { appointmentData.patientID = $0 }
                    ), label: Text(label(.patient))) {
                        ForEach(patients.patients, id: \.patientID) {
                            Text($0.title)
                        }
                    }
                }
                Picker(selection: Binding<UUID>(
                    get: { appointmentData.doctorID ?? UUID() },
                    set: doctorPickerSet
                ), label: Text(label(.doctor))) {
                    ForEach(doctors.doctors.filter{ $0.isDoctor }, id: \.doctorID) { doctor in
                        HStack {
                            Text(doctor.title)
                                .foregroundColor(.primary)
                                .layoutPriority(1)
                            Text(doctor.specialty)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            AppointmentDatesForm(
                appointments: appointments,
                doctors: doctors,
                appointmentData: $appointmentData,
                isUsedByFilter: isUsedByFilter
            )
            DisclosureGroup(label(.services)) {
                ForEach(services.services, id: \.serviceID) { service in
                    ServiceToggle(appointment: $appointmentData, service: service)
                }
            }
            if isUserDoctor {
                CustomSection(header: Text(label(.investigation))) {
                    TextEditor(text: $appointmentData.investigation)
                }
                CustomSection(header: Text(label(.diagnosis))) {
                    TextEditor(text: $appointmentData.diagnosis)
                }
            }
            if !isUsedByFilter {
                NotificationAndCalendarPickers(notificationSchedule: $notificationSchedule, selectedCalendar: $selectedCalendar)
            }
        }
    }
}



struct AppointmentFormGroup_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentFormGroup(
            appointments: Appointments(),
            doctors: Doctors(),
            patients: Patients(),
            services: Services(),
            appointmentData: .constant(Appointment.example),
            notificationSchedule: .constant(NotificationSchedule(description: NSLocalizedString("notificationNone", comment: "Notification Schedule - None"), calendarComponent: .calendar, value: -1)),
            selectedCalendar: .constant(NSLocalizedString("notificationNone", comment: "Notification Schedule - None")),
            isUserDoctor: true,
            isUsedByFilter: false
        )
    }
}
