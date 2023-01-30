//
//  FilterAppointmentsView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 10.04.2021.
//

import SwiftUI

extension FilterAppointments {
    
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var notificationSchedule = NotificationSchedule(description: NSLocalizedString("notificationNone", comment: "Notification Schedule - None"), calendarComponent: .calendar, value: -1)
        @Published var selectedCalendar = NSLocalizedString("notificationNone", comment: "Notification Schedule - None")

        @Published var alertMessage = ""
        @Published var isShowingAlert = false
        
        func applyFilter() {
    //        appointments.filterAppointments(using: filterData) { response in
    //            let generator = UINotificationFeedbackGenerator()
    //            switch response {
    //            case .success(let rs):
    //                self.appointments.appointments = rs
    //                isFilterApplied = true
    //                presentationMode.wrappedValue.dismiss()
    //            case .failure(let error):
    //                error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
    //            }
    //        }
        }
        
        func removeFilter() {
    //        appointments.load() { response in
    //            let generator = UINotificationFeedbackGenerator()
    //            switch response {
    //            case .success(let rs):
    //                self.appointments.appointments = rs
    //                isFilterApplied = false
    //                presentationMode.wrappedValue.dismiss()
    //            case .failure(let error):
    //                error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
    //            }
    //        }
        }
        
        var isUserDoctor: Bool {
            appState.isUserDoctor
        }
    }
}

struct FilterAppointments: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ViewModel
    @ObservedObject var appState: AppState
    @Binding var isFilterApplied: Bool
    @Binding var filterData: Appointment.AppointmentProperties
    let doctorUserID: UUID?
    
    var body: some View {
        Form {
            AppointmentFormGroup(
                appointmentData: $filterData,
                notificationSchedule: $viewModel.notificationSchedule,
                selectedCalendar: $viewModel.selectedCalendar,
                isUsedByFilter: true,
                appState: appState
            )
            if isFilterApplied {
                ListButton(title: label(.removeFilter)) {
                    if viewModel.isUserDoctor {
                        if let doctorUserID = doctorUserID {
                            filterData.doctorID = doctorUserID
                        }
                        viewModel.removeFilter()
                    }
                }
            }
        }
        .navigationTitle(label(.filterAppointments))
        .navigationBarItems(
            leading: Button(label(.cancel)) { dismiss() },
            trailing: Button(label(.filterAction), action: viewModel.applyFilter)
        )
        .alert(isPresented: $viewModel.isShowingAlert) {
            Alert(title: Text(label(.error)), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct FilterAppointments_Previews: PreviewProvider {
    static var previews: some View {
        FilterAppointments(
            viewModel: .init(),
            appState: .shared,
            isFilterApplied: .constant(false),
            filterData: .constant(Appointment.example),
            doctorUserID: nil
        )
    }
}
