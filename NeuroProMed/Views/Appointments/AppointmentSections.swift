//
//  AppointmentsList.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 19.04.2021.
//

import SwiftUI

struct AppointmentSections: View {

    @ObservedObject var appointments: Appointments
    @ObservedObject var doctors: Doctors
    @ObservedObject var patients: Patients
    @ObservedObject var services: Services
    
    @Binding var userID: UUID
    let isUserDoctor: Bool
    let isPatientPerspective: Bool
    let showSorting: Bool
    let useTracking: Bool
    
    @State private var sortedDescending = true
    
    enum AppointmentTimeLine {
        case old, recent, upcoming
    }
    
    func getAppointments(_ appointmentSegment: AppointmentTimeLine) -> [Appointment] {
        let relevantAppointments = isPatientPerspective ? appointments.appointments.filter{ $0.patientID == userID } : appointments.appointments.filter{ $0.doctorID == userID }
        
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
    
    var body: some View {
        Group {
            if !getAppointments(.upcoming).isEmpty {
                CustomSection(header: Text(label(.upcoming)), footer: Text(locationTimeInfo)) {
                    if showSorting {
                        Picker(selection: $sortedDescending, label: Text("Sort")) {
                            Text(label(.sortDescending)).tag(true)
                            Text(label(.sortAscending)).tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    ForEach(getAppointments(.upcoming)) { appointment in
                        UpcomingAppointment(
                            appointments: appointments,
                            doctors: doctors,
                            patients: patients,
                            services: services,
                            appointment: appointment,
                            isPatientPerspective: isPatientPerspective,
                            isUserDoctor: isUserDoctor,
                            useTracking: useTracking
                        )
                    }
                }
            }
            if !getAppointments(.recent).isEmpty  {
                CustomSection(header: Text(String(format: label(.lastXDays), isUserDoctor ? "7" : "30"))) {
                    ForEach(getAppointments(.recent)) { appointment in
                        PastAppointment(
                            appointments: appointments,
                            doctors: doctors,
                            patients: patients,
                            services: services,
                            appointment: appointment,
                            isPatientPerspective: isPatientPerspective,
                            isUserDoctor: isUserDoctor
                        )
                    }
                }
            }
            if !getAppointments(.old).isEmpty {
                CustomSection(header: Text(label(.older))) {
                    ForEach(getAppointments(.old)) { appointment in
                        PastAppointment(
                            appointments: appointments,
                            doctors: doctors,
                            patients: patients,
                            services: services,
                            appointment: appointment,
                            isPatientPerspective: isPatientPerspective,
                            isUserDoctor: isUserDoctor
                        )
                    }
                }
            }
        }
    }
}

struct AppointmentSections_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentSections(
            appointments: Appointments(),
            doctors: Doctors(),
            patients: Patients(),
            services: Services(),
            userID: .constant(UUID()), isUserDoctor: true,
            isPatientPerspective: true,
            showSorting: true,
            useTracking: false
        )
    }
}
