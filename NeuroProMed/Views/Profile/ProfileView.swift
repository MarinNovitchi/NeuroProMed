//
//  ProfileView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 24.04.2021.
//

import SwiftUI

extension ProfileView {
    
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
//        @Published var patient = Patient(using: Patient.PatientProperties())
        var patient: Patient {
            appState.relevantPatient
        }
        @Published var patientData: Patient.PatientProperties = Patient.PatientProperties()
        
//        @Published var doctor = Doctor(using: Doctor.example)
        @Published var doctorData: Doctor.DoctorProperties = Doctor.DoctorProperties()
        var doctor: Doctor {
            appState.relevantDoctor
        }
        
        @Published var alertMessage = ""
        @Published var isShowingAlert = false
        @Published var activeSheet: ActiveSheet?
        
        func deleteKeyChainCredentials() {
            
            let generator = UINotificationFeedbackGenerator()
            let keychainHelper = KeychainHelper()
            do {
                try keychainHelper.deleteCredentials()
                generator.notificationOccurred(.success)
                AppState.shared.useBiometrics = false
                AppState.shared.isAuthenticated = false
            } catch  {
                generator.notificationOccurred(.error)
                alertMessage = label(.failToDeleteKeychain)
                isShowingAlert = true
            }
        }
        
        var isUserDoctor: Bool {
            appState.isUserDoctor
        }
        
        var pageTitle: String {
            isUserDoctor ? doctor.title : patient.title
        }
        
        func edit() {
            isUserDoctor ? editDoctor() : editPatient()
        }
        
        private func editDoctor() {
            doctorData = doctor.data
            activeSheet = .editDoctorSheet
        }
        
        private func editPatient() {
            patientData = patient.data
            activeSheet = .editPatientSheet
        }
        
        enum ActiveSheet: Identifiable {
            case editPatientSheet, editDoctorSheet
            var id: Int {
                hashValue
            }
        }
    }
}

struct ProfileView: View {
    
    @StateObject var viewModel: ViewModel
    @ObservedObject var appState: AppState

    var body: some View {
        NavigationView {
            List {
                if viewModel.isUserDoctor {
                    DoctorDetails(doctor: viewModel.doctor)
                    if viewModel.doctor.unavailability.count > 0 {
                        NavigationLink(String(format: label(.holidayAmount), viewModel.doctorData.unavailability.count), destination:
                            List {
                            HolidaySection(viewModel: .init(), doctorData: $viewModel.doctorData, isSectionEditable: false)
                            }
                            .navigationTitle(label(.holidays))
                        )
                    } else {
                        Text(String(format: label(.holidayAmount), viewModel.doctorData.unavailability.count))
                    }
                } else {
                    PatientDetails(patient: viewModel.patient)
                }
                ListButton(title: label(.logout), action: viewModel.deleteKeyChainCredentials)
            }
//            .onAppear(perform: {
//                viewModel.doctorData = doctor.data
//            })
            .navigationTitle(viewModel.pageTitle)
            .navigationBarItems(trailing: Button(label(.edit), action: viewModel.edit))
            .fullScreenCover(item: $viewModel.activeSheet) { item in
                NavigationView {
                    switch item {
                    case .editDoctorSheet:
                        EditDoctor(
                            viewModel: .init(), doctor: viewModel.doctor,
                            doctorData: $viewModel.doctorData)
                    case .editPatientSheet:
                        EditPatient(
                            viewModel: .init(),
                            patient: viewModel.patient,
                            appState: .shared,
                            patientData: $viewModel.patientData,
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
            viewModel: .init(),
            appState: .shared)
    }
}


