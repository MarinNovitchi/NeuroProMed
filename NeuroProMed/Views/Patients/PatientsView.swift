//
//  PatientsView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.03.2021.
//

import SwiftUI

extension PatientsView {
    
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var isFilterApplied = false
        @Published var activeSheet: ActiveSheet?
        
        enum ActiveSheet: Identifiable {
            case createPatientSheet, filterPatientsSheet
            var id: Int {
                hashValue
            }
        }

        var patientListIndex: [String] {
            var patientsIndexes = [String]()
            for patient in AppState.shared.patients.patients {
                if !patientsIndexes.contains(String(patient.lastName.lowercased().prefix(1))) {
                    patientsIndexes.append(String(patient.lastName.lowercased().prefix(1)))
                }
            }
            return patientsIndexes.sorted(by: { $0 < $1 })
        }
        
        var patients: [Patient] {
            appState.patients.patients
        }
    }
}

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
                trailing: Button(label(.filter)) { viewModel.activeSheet = .filterPatientsSheet }
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
