//
//  AppointmentFormGroup.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.04.2021.
//

import SwiftUI


struct AppointmentFormGroup: View {
    
    @Binding var appointmentData: Appointment.AppointmentProperties
    @Binding var notificationSchedule: NotificationSchedule
    @Binding var selectedCalendar: String
    let isUsedByFilter: Bool
    @ObservedObject var appState: AppState
    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    
    func doctorPickerSet(newValue: UUID) {
        if appState.appointments.appointments.contains(where: { app in
            app.appointmentDate == appointmentData.appointmentDate && app.doctorID == appointmentData.doctorID
        }) {
            appointmentData.appointmentDate = nil
        }
        appointmentData.doctorID = newValue
    }
    
    var entitiesPicker: some View {
        CustomSection(header: Text(label(.appointmentDetails))){
            if appState.isUserDoctor {
                Picker(selection: Binding<UUID>(
                    get: { appointmentData.patientID ?? UUID() },
                    set: { appointmentData.patientID = $0 }
                ), label: Text(label(.patient))) {
                    ForEach(appState.patients.patients, id: \.patientID) {
                        Text($0.title)
                    }
                }
            }
            Picker(selection: Binding<UUID>(
                get: { appointmentData.doctorID ?? UUID() },
                set: doctorPickerSet
            ), label: Text(label(.doctor))) {
                ForEach(appState.doctors.doctors.filter{ $0.isDoctor }, id: \.doctorID) { doctor in
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
    }
    
    @ViewBuilder
    var entitiesPickerView: some View {
        if #available(iOS 16.0, *) {
            entitiesPicker
                .pickerStyle(.navigationLink)
        } else {
            entitiesPicker
        }
    }

    var body: some View {
        Group {
            entitiesPickerView
            AppointmentDatesForm(
                appointmentData: $appointmentData,
                isUsedByFilter: isUsedByFilter,
                appState: appState
            )
            DisclosureGroup(label(.services)) {
                ForEach(appState.services.services, id: \.serviceID) { service in
                    ServiceToggle(appointment: $appointmentData, service: service)
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
            appointmentData: .constant(Appointment.example),
            notificationSchedule: .constant(NotificationSchedule(description: NSLocalizedString("notificationNone", comment: "Notification Schedule - None"), calendarComponent: .calendar, value: -1)),
            selectedCalendar: .constant(NSLocalizedString("notificationNone", comment: "Notification Schedule - None")),
            isUsedByFilter: false,
            appState: .shared
        )
    }
}
