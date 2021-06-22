//
//  PatientsView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.03.2021.
//

import SwiftUI

struct PatientsView: View {
    
    @ObservedObject var appointments: Appointments
    @ObservedObject var doctors: Doctors
    @ObservedObject var patients: Patients
    @ObservedObject var services: Services
    
    @Binding var userID: UUID
    
    @State var isFilterApplied = false
    @State var activeSheet: ActiveSheet?
    
    enum ActiveSheet: Identifiable {
        case createPatientSheet, filterPatientsSheet
        var id: Int {
            hashValue
        }
    }

    var patientListIndex: [String] {
        var patientsIndexes = [String]()
        for patient in patients.patients {
            if !patientsIndexes.contains(String(patient.lastName.lowercased().prefix(1))) {
                patientsIndexes.append(String(patient.lastName.lowercased().prefix(1)))
            }
        }
        return patientsIndexes.sorted(by: { $0 < $1 })
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(patientListIndex, id: \.self) { index in
                    CustomSection(header: Text(index.uppercased())) {
                        ForEach(patients.patients.filter({$0.lastName.lowercased().hasPrefix(index)}).sorted()) { patient in
                            NavigationLink (destination:
                                                PatientView(
                                                    appointments: appointments,
                                                    doctors: doctors,
                                                    patients: patients,
                                                    services: services,
                                                    patient: patient,
                                                    userID: $userID, isUserDoctor: true
                                                )) {
                                PatientRow(patient: patient)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(label(.patients))
            .navigationBarItems(
                leading: Button(label(.new)) { activeSheet = .createPatientSheet },
                trailing: Button(label(.filter)) { activeSheet = .filterPatientsSheet }
                    .foregroundColor(isFilterApplied ? Color("ComplimentaryColor") : .accentColor)
            )
            .fullScreenCover(item: $activeSheet) { item in
                NavigationView {
                    switch item {
                    case .createPatientSheet:
                        CreatePatient(patients: patients)
                    case .filterPatientsSheet:
                        FilterPatients(patients: patients, isFilterApplied: $isFilterApplied)
                    }
                }
            }
        }
    }
}

struct PatientsView_Previews: PreviewProvider {
    static var previews: some View {
        PatientsView(
            appointments: Appointments(),
            doctors: Doctors(),
            patients: Patients(),
            services: Services(),
            userID: .constant(UUID())
        )
    }
}
