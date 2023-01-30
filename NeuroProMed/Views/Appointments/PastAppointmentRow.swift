//
//  PastAppointmentRow.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 04.04.2021.
//

import SwiftUI

struct PastAppointmentRow: View {
    
    @ObservedObject var appState: AppState
    @ObservedObject var appointment: Appointment
    @ObservedObject var doctor: Doctor
    @ObservedObject var patient: Patient
    let isPatientPerspective: Bool
    
    var filteredServices: [Service] {
        appState.services.services.filter {
            appointment.services.contains($0.serviceID)
        }
    }
    
    var body: some View {
        HStack {
            Image("neuropromed_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
            VStack(alignment: .leading) {
                Text(appointment.formattedAppointmentDate)
                    .foregroundColor(.accentColor)
                    .bold()
                Text(isPatientPerspective ? doctor.title : patient.title )
                    .foregroundColor(.secondary)
            }
            Spacer()
            if filteredServices.count > 0 {
                Label(String(filteredServices.count), systemImage: "stethoscope")
                    .foregroundColor(.white)
                    .padding(3)
                    .background(Color("ComplimentaryColor"))
                    .clipShape(Capsule())
            }
        }
    }
}

struct PastAppointmentRow_Previews: PreviewProvider {
    static var previews: some View {
        PastAppointmentRow(
            appState: .shared,
            appointment: Appointment(using: Appointment.example),
            doctor: Doctor(using: Doctor.example),
            patient: Patient(using: Patient.example),
            isPatientPerspective: true)
    }
}
