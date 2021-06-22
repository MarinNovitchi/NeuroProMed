//
//  ProfileView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 24.04.2021.
//

import SwiftUI

struct ProfileView: View {
    
    @ObservedObject var appointments: Appointments
    
    @ObservedObject var patient: Patient
    @ObservedObject var doctor: Doctor
    
    @Binding var useBiometrics: Bool
    @Binding var isAuthenticated: Bool
    let isUserDoctor: Bool
    
    @State private var patientData: Patient.PatientProperties = Patient.PatientProperties()
    @State private var doctorData: Doctor.DoctorProperties = Doctor.DoctorProperties()
    
    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    @State var activeSheet: ActiveSheet?
    enum ActiveSheet: Identifiable {
        case editPatientSheet, editDoctorSheet
        var id: Int {
            hashValue
        }
    }
    
    func deleteKeyChainCredentials() {
        
        let generator = UINotificationFeedbackGenerator()
        let keychainHelper = KeychainHelper()
        do {
            try keychainHelper.deleteCredentials()
            generator.notificationOccurred(.success)
            useBiometrics = false
            isAuthenticated = false
        } catch  {
            generator.notificationOccurred(.error)
            alertMessage = label(.failToDeleteKeychain)
            isShowingAlert = true
        }
    }

    var body: some View {
        NavigationView {
            List {
                if isUserDoctor {
                    DoctorDetails(doctor: doctor)
                    if doctor.unavailability.count > 0 {
                        NavigationLink(String(format: label(.holidayAmount), doctorData.unavailability.count), destination:
                            List {
                                HolidaySection(doctorData: $doctorData, isSectionEditable: false)
                            }
                            .navigationTitle(label(.holidays))
                        )
                    } else {
                        Text(String(format: label(.holidayAmount), doctorData.unavailability.count))
                    }
                } else {
                    PatientDetails(patient: patient)
                }
                ListButton(title: label(.logout), action: deleteKeyChainCredentials)
            }
            .onAppear(perform: { doctorData = doctor.data })
            .navigationTitle(isUserDoctor ? doctor.title : patient.title)
            .navigationBarItems(trailing:
                Button(label(.edit)) {
                    if isUserDoctor {
                        doctorData = doctor.data
                        activeSheet = .editDoctorSheet
                    } else {
                        patientData = patient.data
                        activeSheet = .editPatientSheet
                    }
                })
            .fullScreenCover(item: $activeSheet) { item in
                NavigationView {
                    switch item {
                    case .editDoctorSheet:
                        EditDoctor(
                            appointments: appointments,
                            doctor: doctor,
                            doctorData: $doctorData,
                            useBiometrics: $useBiometrics)
                    case .editPatientSheet:
                        EditPatient(
                            patient: patient,
                            patientData: $patientData,
                            useBiometrics: $useBiometrics,
                            showBiometrics: true)
                    }
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(
            appointments: Appointments(),
            patient: Patient(using: Patient.example),
            doctor: Doctor(using: Doctor.example),
            useBiometrics: .constant(true),
            isAuthenticated: .constant(true),
            isUserDoctor: true)
    }
}


