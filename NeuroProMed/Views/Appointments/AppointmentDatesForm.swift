//
//  AppointmentDatesForm.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 24.04.2021.
//

import SwiftUI

struct AppointmentDatesForm: View {
    
    @ObservedObject var appointments: Appointments
    @ObservedObject var doctors: Doctors
    
    @Binding var appointmentData: Appointment.AppointmentProperties
    let isUsedByFilter: Bool
    
    @State private var chosenDate = Date()
    @State private var chosenTime = "08:00"
    @State private var appointmentAvailability: [Date: [String]] = [Date: [String]]()
    
    var formattedChosenDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return String(format: label(.appointmentDateDisclosureLabel), formatter.string(from: chosenDate))
    }
    
    func bookTimeSlot(_ choice: String) {
        let timeArray = choice.split(separator: Character(":"))
        if timeArray.count > 1 {
            if let bookedHour = Int(timeArray[0]), let bookedMinutes = Int(timeArray[1]) {
                if let bookedDate = Calendar.current.date(bySettingHour: bookedHour, minute: bookedMinutes, second: 0, of: chosenDate) {
                    appointmentData.appointmentDate = bookedDate
                }
            }
        }
    }
    
    func prepareDateAndTimePickers() {
        guard let doctor = doctors.doctors.first(where: { $0.doctorID == appointmentData.doctorID }) else {
            return
        }
        
        let helper = AppointmentHelper()
        appointmentAvailability = helper.computeDoctorAvailability(for: doctor, from: appointments.appointments)
        
        if let unwrappedDate = appointmentData.appointmentDate {
            chosenTime = helper.getTimeSlot(from: unwrappedDate)
            chosenDate = unwrappedDate.setToMidDayGMT()
            
        } else {
            chosenDate = helper.getNearestUpcomingDate(from: Array(appointmentAvailability.keys))
            if let firstDaySlots = appointmentAvailability[chosenDate] {
                chosenTime = firstDaySlots.sorted()[0]
            }
        }
        bookTimeSlot(chosenTime)
    }
    
    var body: some View {
        if isUsedByFilter {
            CustomSection(header: Text(label(.appointmentTime))) {
                DatePicker(label(.dateFrom), selection: $appointmentData.appointmentDateFrom, displayedComponents: .date)
                DatePicker(label(.dateTo), selection: $appointmentData.appointmentDateTo, displayedComponents: .date)
            }
        } else {
            CustomSection(header: Text(label(.appointmentTime))) {
                DisclosureGroup(formattedChosenDate) {
                    Picker(label(.date), selection: Binding<Date>(
                        get: { chosenDate },
                        set: { chosenDate = $0
                            if !(appointmentAvailability[chosenDate]?.contains(chosenTime) ?? true) {
                                chosenTime = "08:00"
                            }
                            bookTimeSlot(chosenTime)
                        }
                    )) {
                        ForEach(Array(appointmentAvailability.keys).sorted(by: { $0.compare($1) == .orderedDescending }), id: \.self) {
                            Text($0, style: .date)
                        }
                    }
                }
                DisclosureGroup(String(format: label(.appointmentTimeDisclosureLabel), chosenTime)) {
                    Picker(label(.time), selection: Binding<String>(
                        get: { chosenTime },
                        set: { chosenTime = $0
                            bookTimeSlot(chosenTime)
                        }
                    )) {
                        if let timeslots = appointmentAvailability[chosenDate.setToMidDayGMT()]  {
                            ForEach(timeslots.sorted(by: >), id: \.self) {
                                Text($0)
                            }
                        }
                    }
                }
            }
            .pickerStyle(InlinePickerStyle())
            .onAppear(perform: !isUsedByFilter ? prepareDateAndTimePickers : {})
        }
    }
}

struct AppointmentDatesForm_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentDatesForm(
            appointments: Appointments(),
            doctors: Doctors(),
            appointmentData: .constant(Appointment.example),
            isUsedByFilter: false
        )
    }
}
