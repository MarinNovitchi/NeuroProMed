//
//  AddHoliday.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 23.05.2021.
//

import SwiftUI

struct AddHoliday: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var appointments: Appointments
    
    @Binding var doctorData: Doctor.DoctorProperties
    
    @State private var dateToAdd = Date()
    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    
    func addDayOff() {
        if isValidForDayOff() {
            if !doctorData.unavailability.contains(dateToAdd.setToMidDayGMT()) {
                doctorData.unavailability.append(dateToAdd.setToMidDayGMT())
                doctorData.unavailability.sort(by: { $0.compare($1) == .orderedAscending })
            }
            presentationMode.wrappedValue.dismiss()
        } else {
            alertMessage = label(.invalidHolidayMessage)
            isShowingAlert = true
        }
    }
    
    func isValidForDayOff() -> Bool {
        return !appointments.appointments.contains{
            $0.doctorID == doctorData.doctorID && dateToAdd.setToMidDayGMT().compare($0.appointmentDate.setToMidDayGMT()) == .orderedSame
        }
    }
    
    var body: some View {
        DatePicker("Pick a date", selection: $dateToAdd, in: Date()..., displayedComponents: .date)
            .datePickerStyle(GraphicalDatePickerStyle())
            .navigationTitle(label(.addNewHoliday))
            .navigationBarItems(
                leading: Button(label(.cancel)) { presentationMode.wrappedValue.dismiss() } ,
                trailing: Button(label(.add), action: addDayOff))
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text(label(.error)), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
    }
}

struct AddHoliday_Previews: PreviewProvider {
    static var previews: some View {
        AddHoliday(appointments: Appointments(), doctorData: .constant(Doctor.example))
    }
}
