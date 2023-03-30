//
//  AppointmentsList.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 19.04.2021.
//

import SwiftUI

struct AppointmentSections: View {
    
    @StateObject var viewModel: ViewModel
    @ObservedObject var appState: AppState
    let isPatientPerspective: Bool
    let showSorting: Bool
    let useTracking: Bool
    
    var upcomingAppointmentsSection: some View {
        CustomSection(header: Text(label(.upcoming)), footer: Text(viewModel.locationTimeInfo)) {
            if showSorting {
                Picker(selection: $viewModel.sortedDescending, label: Text("Sort")) {
                    Text(label(.sortDescending)).tag(true)
                    Text(label(.sortAscending)).tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            ForEach(viewModel.getAppointments(.upcoming, isPatientPerspective: isPatientPerspective)) { appointment in
                UpcomingAppointment(
                    appState: appState,
                    appointment: appointment,
                    isPatientPerspective: isPatientPerspective,
                    useTracking: useTracking
                )
            }
        }
    }
    
    var recentAppointmentsSection: some View {
        CustomSection(header: Text(String(format: label(.lastXDays), viewModel.isUserDoctor ? "7" : "30"))) {
            ForEach(viewModel.getAppointments(.recent, isPatientPerspective: isPatientPerspective)) { appointment in
                PastAppointment(
                    appointment: appointment,
                    appState: appState,
                    isPatientPerspective: isPatientPerspective
                )
            }
        }
    }
    var oldAppointmentsSection: some View {
        CustomSection(header: Text(label(.older))) {
            ForEach(viewModel.getAppointments(.old, isPatientPerspective: isPatientPerspective)) { appointment in
                PastAppointment(
                    appointment: appointment,
                    appState: appState,
                    isPatientPerspective: isPatientPerspective
                )
            }
        }
    }
    
    var body: some View {
        Group {
            if viewModel.shouldShowAppointmentsSection(.upcoming, isPatientPerspective: isPatientPerspective) {
                upcomingAppointmentsSection
            }
            if viewModel.shouldShowAppointmentsSection(.recent, isPatientPerspective: isPatientPerspective)  {
                recentAppointmentsSection
            }
            if viewModel.shouldShowAppointmentsSection(.old, isPatientPerspective: isPatientPerspective) {
                oldAppointmentsSection
            }
        }
    }
}

struct AppointmentSections_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentSections(
            viewModel: .init(),
            appState: .shared,
            isPatientPerspective: true,
            showSorting: true,
            useTracking: false
        )
    }
}
