//
//  MainView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 11.06.2021.
//

import SwiftUI

struct MainView: View {
    
    @ObservedObject var appState = AppState.shared
    
    @Binding var userID: UUID
    @Binding var isUserDoctor: Bool
    @Binding var isAuthenticated: Bool
    @Binding var useBiometrics: Bool
    
    @State private var doctors = Doctors()
    @State private var services = Services()
    @State private var patients = Patients()
    @State private var appointments = Appointments()
    
    @State private var selectedTab = 0
    
    @State private var relevantPatient = Patient(using: Patient.PatientProperties())
    @State private var relevantDoctor = Doctor(using: Doctor.example)
    
    @State private var alertMessage = ""
    @State var activeAlert: ActiveAlert?
    
    func loadData() {
        let generator = UINotificationFeedbackGenerator()
        appointments.load() { response in
            switch response {
            case .success(let rs):
                appointments.appointments = rs
            case .failure(let error):
                error.trigger(with: generator, &activeAlert, message: &alertMessage)
            }
        }
        doctors.load() { response in
            switch response {
            case .success(let rs):
                doctors.doctors = rs
                if isUserDoctor {
                    if let foundDoctor = rs.first(where: { $0.doctorID == userID }) {
                        relevantDoctor = foundDoctor
                    } else {
                        isAuthenticated = false
                    }
                }

            case .failure(let error):
                error.trigger(with: generator, &activeAlert, message: &alertMessage)
            }
        }
        patients.load() { response in
            switch response {
            case .success(let rs):
                patients.patients = rs
                if !isUserDoctor {
                    if let foundPatient = rs.first(where: { $0.patientID == userID }) {
                        relevantPatient = foundPatient
                    } else {
                        isAuthenticated = false
                    }
                }
            case .failure(let error):
                error.trigger(with: generator, &activeAlert, message: &alertMessage)
            }
        }
        services.load() { response in
            switch response {
            case .success(let rs):
                services.services = rs
            case .failure(let error):
                error.trigger(with: generator, &activeAlert, message: &alertMessage)
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            if isUserDoctor {
                PatientsView(appointments: appointments, doctors: doctors, patients: patients, services: services, userID: $userID)
                    .tabItem {
                        Image(systemName: "person.3.fill")
                        Text(label(.patients))
                    }
                    .tag(0)
            }
            AppointmentsView(appointments: appointments, doctors: doctors, patients: patients, services: services, userID: $userID, isUserDoctor: isUserDoctor)
                .tabItem {
                    Image(systemName: "calendar.badge.clock")
                    Text(label(.appointments))
                }
                .tag(1)
            ProfileView(appointments: appointments, patient: relevantPatient, doctor: relevantDoctor, useBiometrics: $useBiometrics, isAuthenticated: $isAuthenticated, isUserDoctor: isUserDoctor)
                .tabItem {
                    Image(systemName: "person.crop.rectangle.fill")
                    Text(label(.myProfile))
                }
                .tag(2)
        }
        .listStyle(InsetGroupedListStyle())
        .onAppear(perform: loadData)
        .onReceive(appState.$selectedAppointmentID) { publisher in
            selectedTab = 1
        }
        .alert(item: $activeAlert) { item in
            switch item {
            case .warning:
                fallthrough
            case .error:
                return Alert(title: Text(label(.error)), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            case .settingsIssue:
                return Alert(
                    title: Text(label(.biometricsPermissionDenied)),
                    message: Text(alertMessage),
                    primaryButton: .cancel(),
                    secondaryButton: .default(Text(label(.appSettings)), action: {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    })
                )
            }
            
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(userID: .constant(UUID()),
                 isUserDoctor: .constant(false),
                 isAuthenticated: .constant(true),
                 useBiometrics: .constant(true))
    }
}
