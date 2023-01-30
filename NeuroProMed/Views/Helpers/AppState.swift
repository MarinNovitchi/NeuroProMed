//
//  AppState.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 16.05.2021.
//

import Foundation


/// Class with a published selectedAppointmentID to be used when the application is opened via a notification tap and the appointmentView must be shown
class AppState: ObservableObject {
    
    static let shared = AppState()
    @Published var selectedAppointmentID : String?
    
    @Published var doctors = Doctors()
    @Published var services = Services()
    @Published var patients = Patients()
    @Published var appointments = Appointments()
    
    @Published var relevantPatient = Patient(using: Patient.PatientProperties())
    @Published var relevantDoctor = Doctor(using: Doctor.example)
    
    @Published var userID = UUID()
    @Published var isUserDoctor = false
    @Published var isAuthenticated = false
    
    @Published var useBiometrics = false
    @Published var isUnlocked = false
    
    func loadData() async throws {
        
        appointments.appointments = try await appointments.load()
        doctors.doctors = try await doctors.load()
        if isUserDoctor {
            if let foundDoctor = doctors.doctors.first(where: { $0.doctorID == userID }) {
                relevantDoctor = foundDoctor
            } else {
                isAuthenticated = false
            }
        }
        patients.patients = try await patients.load()
        print("Patients: \(patients.patients.count)")
        if !isUserDoctor {
            if let foundPatient = patients.patients.first(where: { $0.patientID == userID }) {
                relevantPatient = foundPatient
            } else {
                isAuthenticated = false
            }
        }
        services.services = try await services.load()
        objectWillChange.send()
    }
}
