//
//  AppointmentsView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2021.
//

import SwiftUI

extension AppointmentsView {
    
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var isFilterApplied = false
        @Published var appointmentData = Appointment.AppointmentProperties(doctorID: UUID(), patientID: UUID())
        
        @Published var activeSheet: ActiveSheet?
        enum ActiveSheet: Identifiable {
            case createAppointmentSheet, filterAppointmentsSheet
            var id: Int {
                hashValue
            }
        }
        
        func triggerAppointmentCreation() {
            resetAppointmentData()
            activeSheet = .createAppointmentSheet
        }
        
        func triggerAppointmentFiltering() {
            resetAppointmentData()
            activeSheet = .filterAppointmentsSheet
        }
        
        func resetAppointmentData() {
            appointmentData = appState.isUserDoctor ?
            Appointment.AppointmentProperties(
                doctorID: appState.userID,
                patientID: appState.patients.patients.first?.patientID ?? UUID())
            : Appointment.AppointmentProperties(
                doctorID: appState.doctors.doctors.first?.doctorID ?? UUID(),
                patientID: appState.userID)
        }
        
        var isUserDoctor: Bool {
            appState.isUserDoctor
        }
    }
}

struct AppointmentsView: View {
    
    @StateObject var viewModel: ViewModel
    @ObservedObject var appState: AppState

    var body: some View {
        NavigationView {
            List {
                AppointmentSections(
                    viewModel: .init(),
                    appState: appState,
                    isPatientPerspective: !viewModel.isUserDoctor,
                    showSorting: true,
                    useTracking: true
                )
            }
            .navigationTitle(label(.appointments))
            .navigationBarItems(
                leading: Button(label(.new), action: viewModel.triggerAppointmentCreation),
                trailing: Button(label(.filter), action: viewModel.triggerAppointmentFiltering) 
                    .foregroundColor(viewModel.isFilterApplied ? Color("ComplimentaryColor") : .accentColor)
            )
            .fullScreenCover(item: $viewModel.activeSheet) { item in
                NavigationView {
                    switch item {
                    case .createAppointmentSheet:
                        CreateAppointment(viewModel: .init(), appState: appState, appointmentData: $viewModel.appointmentData)
                    case .filterAppointmentsSheet:
                        FilterAppointments(
                            viewModel: .init(),
                            appState: appState,
                            isFilterApplied: $viewModel.isFilterApplied,
                            filterData: $viewModel.appointmentData,
                            doctorUserID: appState.userID
                        )
                    }
                }
            }
        }
    }
}


struct AppointmentsView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentsView(viewModel: .init(), appState: .shared
        )
    }
}
