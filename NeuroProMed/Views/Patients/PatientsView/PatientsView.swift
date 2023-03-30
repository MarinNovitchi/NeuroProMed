//
//  PatientsView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.03.2021.
//

import SwiftUI

struct PatientsView: View {
    
    @StateObject var viewModel: ViewModel
    @ObservedObject var appState: AppState
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.patientListIndex, id: \.self) { index in
                    CustomSection(header: Text(index.uppercased())) {
                        ForEach(viewModel.patients.filter({$0.lastName.lowercased().hasPrefix(index)}).sorted()) { patient in
                            NavigationLink (destination: PatientView(patient: patient, viewModel: .init())) {
                                PatientRow(patient: patient)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(label(.patients))
            .navigationBarItems(
                leading: Button(label(.new)) { viewModel.activeSheet = .createPatientSheet },
                trailing: Button(label(.filter)) {
                    viewModel.activeSheet = .filterPatientsSheet
                }
                .foregroundColor(viewModel.isFilterApplied ? Color("ComplimentaryColor") : .accentColor)
            )
            .fullScreenCover(item: $viewModel.activeSheet) { item in
                NavigationView {
                    switch item {
                    case .createPatientSheet:
                        CreatePatient(viewModel: .init())
                    case .filterPatientsSheet:
                        FilterPatients(viewModel: .init(), isFilterApplied: $viewModel.isFilterApplied)
                    }
                }
            }
        }
    }
}

struct PatientsView_Previews: PreviewProvider {
    static var previews: some View {
        PatientsView(viewModel: .init(), appState: .shared)
    }
}
