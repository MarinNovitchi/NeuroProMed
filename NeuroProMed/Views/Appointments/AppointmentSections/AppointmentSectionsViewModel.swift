//
//  AppointmentSectionsViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Foundation

extension AppointmentSections {
    
    @MainActor
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
