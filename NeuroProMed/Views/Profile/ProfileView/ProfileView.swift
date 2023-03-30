//
//  ProfileView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 24.04.2021.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject var viewModel: ViewModel
    @ObservedObject var appState: AppState

    var body: some View {
        NavigationView {
            List {
                if viewModel.isUserDoctor {
                    DoctorDetails(doctor: viewModel.doctor)
                    if viewModel.hasUnavailability {
                        NavigationLink(String(format: label(.holidayAmount), viewModel.unavailabilityCount), destination:
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
                ListButton(title: label(.logout)) { viewModel.deleteKeyChainCredentials() }
            }
            .navigationTitle(viewModel.pageTitle)
            .navigationBarItems(trailing: Button(label(.edit)) { viewModel.edit() })
            .fullScreenCover(item: $viewModel.activeSheet) { item in
                NavigationView {
                    switch item {
                    case .editDoctorSheet:
                        EditDoctor(
                            viewModel: .init(), doctor: viewModel.doctor,
                            doctorData: $viewModel.doctorData,
                            appState: appState)
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


