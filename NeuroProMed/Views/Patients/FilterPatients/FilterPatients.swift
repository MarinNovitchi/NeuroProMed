//
//  FilterPatients.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 04.04.2021.
//

import SwiftUI

struct FilterPatients: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ViewModel
    @Binding var isFilterApplied: Bool

    var body: some View {
        Form {
            PatientDetailsSection(patientData: $viewModel.filterData, isUsedByFilter: true)
            if isFilterApplied {
                ListButton(title: label(.removeFilter)) { viewModel.removeFilter() }
            }
        }
        .onReceive(viewModel.isFilterApplied) { isApplied in
            if let isApplied {
                isFilterApplied = isApplied
                dismiss()
            }
        }
        .navigationTitle(label(.filterPatients))
        .navigationBarItems(
            leading: Button(label(.cancel)) { dismiss() },
            trailing: Button(label(.filterAction)) { viewModel.applyFilter() }
        )
    }
}

struct FilterPatients_Previews: PreviewProvider {
    static var previews: some View {
        FilterPatients(viewModel: .init(), isFilterApplied: .constant(true))
    }
}
