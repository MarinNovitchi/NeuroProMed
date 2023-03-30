//
//  AddHolidayViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Combine
import Foundation

extension AddHoliday {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var alertMessage = ""
        @Published var isShowingAlert = false
        
        @Published var dateToAdd = Date()
        
        let dismissView = CurrentValueSubject<Bool, Never>(false)
        
        func addHoliday(to doctorData: inout Doctor.DoctorProperties) {
            if addingDayOff(to: &doctorData) {
                dismissView.send(true)
            } else {
                alertMessage = label(.invalidHolidayMessage)
                isShowingAlert = true
            }
        }
        
        func addingDayOff(to doctorData: inout Doctor.DoctorProperties) -> Bool {
            guard isValidForDayOff(doctorData: doctorData) else {
                return false
            }
            if !doctorData.unavailability.contains(dateToAdd.setToMidDayGMT()) {
                doctorData.unavailability.append(dateToAdd.setToMidDayGMT())
                doctorData.unavailability.sort(by: { $0.compare($1) == .orderedAscending })
            }
            return true
        }
        
        func isValidForDayOff(doctorData: Doctor.DoctorProperties) -> Bool {
            !appState.appointments.appointments.contains{
                $0.doctorID == doctorData.doctorID && dateToAdd.setToMidDayGMT().compare($0.appointmentDate.setToMidDayGMT()) == .orderedSame
            }
        }
    }
}
