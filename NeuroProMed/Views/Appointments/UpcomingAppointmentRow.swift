//
//  UpcomingAppointmentRow.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.05.2021.
//

import SwiftUI

extension UpcomingAppointmentRow {
    
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        func getFilteredServices(for appointment: Appointment) -> [Service] {
            appState.services.services.filter({ appointment.services.contains($0.serviceID) })
        }
        
        func isAppointmentClose(_ appointment: Appointment) -> Bool {
            if let hoursDifference = Calendar.current.dateComponents([.hour], from: Date(), to: appointment.appointmentDate).hour {
                return hoursDifference < 1
            }
            return false
        }
    }
}


struct UpcomingAppointmentRow: View {
    
    @StateObject var viewModel: ViewModel
    @ObservedObject var appointment: Appointment
    @ObservedObject var doctor: Doctor
    @ObservedObject var patient: Patient
    @ObservedObject var appState: AppState
    
    let isPatientPerspective: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                VStack (alignment: .leading) {
                    Label(label(.time), systemImage: "clock")
                        .foregroundColor(.secondary)
                        .padding(.top, 3)
                    Text(appointment.appointmentDate, style: .time)
                        .bold()
                        .foregroundColor(.accentColor)
                        .padding(.bottom, 3)
                    Label(label(.date), systemImage: "calendar")
                        .foregroundColor(.secondary)
                    Text(appointment.appointmentDate, style: .date).bold()
                        .foregroundColor(.accentColor)
                        .padding(.bottom, 3)
                }
            }
            Divider()
            VStack(alignment: .leading) {
                Text(isPatientPerspective ? doctor.title : patient.title)
                    .bold()
                Text(appointment.appointmentDate, style: viewModel.isAppointmentClose(appointment) ? .timer : .relative)
                    .foregroundColor(.secondary)
                ForEach(viewModel.getFilteredServices(for: appointment)) { service in
                    Label(service.name, systemImage: "stethoscope")
                        .foregroundColor(.white)
                        .padding(3)
                        .background(Color("ComplimentaryColor"))
                        .clipShape(Capsule())
                        
                }
            
            } .padding(.leading, 5)
        }
    }
}

struct UpcomingAppointmentRow_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingAppointmentRow(
            viewModel: .init(),
            appointment: Appointment(using: Appointment.example),
            doctor: Doctor(using: Doctor.example),
            patient: Patient(using: Patient.example),
            appState: .shared,
            isPatientPerspective: true
        )
    }
}
