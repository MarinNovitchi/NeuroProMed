//
//  AppointmentsList.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 19.04.2021.
//

import SwiftUI

extension AppointmentSections {
    
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var sortedDescending = true
        
        enum AppointmentTimeLine {
            case old, recent, upcoming
        }
        
        func getAppointments(_ appointmentSegment: AppointmentTimeLine, isPatientPerspective: Bool) -> [Appointment] {
            let relevantAppointments = isPatientPerspective ? appState.appointments.appointments.filter{ $0.patientID == appState.userID } : appState.appointments.appointments.filter{ $0.doctorID == appState.userID }
            
            switch appointmentSegment {
            case .upcoming:
                if sortedDescending {
                    return relevantAppointments.filter{ $0.appointmentDate.compare(Date()) != .orderedAscending }.sorted(by: <)
                } else {
                    return relevantAppointments.filter{ $0.appointmentDate.compare(Date()) != .orderedAscending }.sorted(by: >)
                }
            case .recent:
                return relevantAppointments.filter{ $0.appointmentDate.compare(Date()) == .orderedAscending && isRecent($0.appointmentDate) }.sorted()
            case .old:
                return relevantAppointments.filter{ $0.appointmentDate.compare(Date()) == .orderedAscending && !isRecent($0.appointmentDate) }.sorted()
            }
        }
        
        var locationTimeInfo: String {
            let zoneIdentifierArray = TimeZone.current.identifier.split(separator: Character("/"))
            if zoneIdentifierArray.count > 1 {
                return String(format: label(.xTime), zoneIdentifierArray[1] as CVarArg)
            }
            return label(.unknownTimeLocation)
        }
        
        func isRecent(_ argDate: Date) -> Bool {
            if isUserDoctor {
                return Calendar.current.dateComponents([.weekOfYear], from: argDate, to: Date()).weekOfYear ?? 1 < 1
            } else {
                return Calendar.current.dateComponents([.month], from: argDate, to: Date()).month ?? 1 < 1
            }
        }
        
        func shouldShowAppointmentsSection(_ appointmentSegment: AppointmentTimeLine, isPatientPerspective: Bool) -> Bool {
            !getAppointments(appointmentSegment, isPatientPerspective: isPatientPerspective).isEmpty
        }
        
        var isUserDoctor: Bool {
            appState.isUserDoctor
        }
    }
}

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
