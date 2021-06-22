//
//  UpcomingAppointmentRow.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.05.2021.
//

import SwiftUI


struct UpcomingAppointmentRow: View {
    
    @ObservedObject var appointments: Appointments
    @ObservedObject var doctors: Doctors
    @ObservedObject var patients: Patients
    @ObservedObject var services: Services
    
    @ObservedObject var appointment: Appointment
    @ObservedObject var doctor: Doctor
    @ObservedObject var patient: Patient
    
    let isPatientPerspective: Bool
    
    var filteredServices: [Service] {
        services.services.filter({ appointment.services.contains($0.serviceID) })
    }
    
    var isAppointmentClose: Bool {
        if let hoursDifference = Calendar.current.dateComponents([.hour], from: Date(), to: appointment.appointmentDate).hour {
            return hoursDifference < 1
        }
        return false
    }
    
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
                Text(appointment.appointmentDate, style: isAppointmentClose ? .timer : .relative)
                    .foregroundColor(.secondary)
                ForEach(filteredServices) { service in
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
            appointments: Appointments(),
            doctors: Doctors(),
            patients: Patients(),
            services: Services(),
            appointment: Appointment(using: Appointment.example),
            doctor: Doctor(using: Doctor.example),
            patient: Patient(using: Patient.example),
            isPatientPerspective: true
        )
    }
}
