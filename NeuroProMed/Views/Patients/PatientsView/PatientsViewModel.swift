//
//  PatientsViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Foundation

extension PatientsView {
    
    @MainActor
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
