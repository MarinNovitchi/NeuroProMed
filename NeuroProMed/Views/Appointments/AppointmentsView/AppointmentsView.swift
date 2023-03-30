//
//  AppointmentsView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2021.
//

import SwiftUI

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
                leading: Button(label(.new)) { viewModel.triggerAppointmentCreation() },
                trailing: Button(label(.filter)) { viewModel.triggerAppointmentFiltering() }
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
