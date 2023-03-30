//
//  FilterAppointmentsView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 10.04.2021.
//

import SwiftUI

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
                    }
                    viewModel.removeFilter()
                }
            }
        }
        .onReceive(viewModel.isFilterApplied) { isApplied in
            if let isApplied {
                isFilterApplied = isApplied
                dismiss()
            }
        }
        .navigationTitle(label(.filterAppointments))
        .navigationBarItems(
            leading: Button(label(.cancel)) { dismiss() },
            trailing: Button(label(.filterAction)) {
                viewModel.applyFilter(using: filterData)
            }
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
