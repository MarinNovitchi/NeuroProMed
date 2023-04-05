//
//  UpcomingAppointmentRowViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Foundation

extension UpcomingAppointmentRow {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        func getFilteredServices(for appointment: Appointment) -> [Service] {
            appState.services.services.filter { service in
                appointment.appointmentServices.contains { $0.serviceID == service.serviceID }
            }
        }
        
        func isAppointmentClose(_ appointment: Appointment) -> Bool {
            if let hoursDifference = Calendar.current.dateComponents([.hour], from: Date(), to: appointment.appointmentDate).hour {
                return hoursDifference < 1
            }
            return false
        }
    }
}
