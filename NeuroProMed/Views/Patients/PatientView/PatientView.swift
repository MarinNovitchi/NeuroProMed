//
//  PatientView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.03.2021.
//

import SwiftUI

struct PatientView: View {
    
    @ObservedObject var patient: Patient
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        List {
            PatientDetails(patient: patient)
            ListButton(title: label(.createAppointment)) {
                viewModel.createAppointment(for: patient)
            }
            AppointmentSections(
                viewModel: .init(),
                appState: .shared,
                isPatientPerspective: true,//patient.patientID,
                showSorting: false,
                useTracking: false
            )
            PatientDeleteButton(viewModel: .init(), patient: patient, appState: .shared)
        }
        .navigationBarTitle(Text(patient.title), displayMode: .inline)
        .navigationBarItems(trailing:
                Button(label(.edit)) {
                viewModel.patientData = patient.data
                viewModel.activeSheet = .editPatientSheet
            })
        .fullScreenCover(item: $viewModel.activeSheet) { item in
            NavigationView {
                switch item {
                case .editPatientSheet:
                    EditPatient(
                        viewModel: .init(),
                        patient: patient,
                        appState: .shared,
                        patientData: $viewModel.patientData,
                        showBiometrics: false
                    )
                case .createAppointmentSheet:
                    CreateAppointment(
                        viewModel: .init(),
                        appState: .shared,
                        appointmentData: $viewModel.appointmentData
                    )
                }
            }
        }
    }
}

struct PatientView_Previews: PreviewProvider {

    static var previews: some View {
        PatientView(patient: Patient(using: Patient.example), viewModel: .init())
    }
}
