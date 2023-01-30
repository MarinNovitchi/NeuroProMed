//
//  AddHoliday.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 23.05.2021.
//

import SwiftUI

extension AddHoliday {
    
    class ViewModel: ObservableObject {
        
        init(doctorData: Doctor.DoctorProperties) {
            self.doctorData = doctorData
        }
        
        @Published var dateToAdd = Date()
        @Published var doctorData: Doctor.DoctorProperties
        
        func addingDayOff() -> Bool {
            guard isValidForDayOff else {
                return false
            }
            if !doctorData.unavailability.contains(dateToAdd.setToMidDayGMT()) {
                doctorData.unavailability.append(dateToAdd.setToMidDayGMT())
                doctorData.unavailability.sort(by: { $0.compare($1) == .orderedAscending })
            }
            return true
        }
        
        var isValidForDayOff: Bool {
            !AppState.shared.appointments.appointments.contains{
                $0.doctorID == doctorData.doctorID && dateToAdd.setToMidDayGMT().compare($0.appointmentDate.setToMidDayGMT()) == .orderedSame
            }
        }
    }
}

struct AddHoliday: View {
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    @Environment(\.dismiss) var dismiss

    @StateObject var viewModel: ViewModel
    
    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    
    var body: some View {
        DatePicker("Pick a date", selection: $viewModel.dateToAdd, in: Date()..., displayedComponents: .date)
            .datePickerStyle(.graphical)
            .navigationTitle(label(.addNewHoliday))
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text(label(.error)), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(label(.cancel)) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(label(.add)) {
                        if viewModel.addingDayOff() {
                            dismiss()
                        } else {
                            alertMessage = label(.invalidHolidayMessage)
                            isShowingAlert = true
                        }
                    }
                }
            }
    }
}

struct AddHoliday_Previews: PreviewProvider {
    static var previews: some View {
        AddHoliday(viewModel: .init(doctorData: Doctor.example))
    }
}
