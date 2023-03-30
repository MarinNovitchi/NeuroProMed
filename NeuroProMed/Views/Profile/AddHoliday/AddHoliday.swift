//
//  AddHoliday.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 23.05.2021.
//

import SwiftUI

struct AddHoliday: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var doctorData: Doctor.DoctorProperties
    @StateObject var viewModel: ViewModel
    @ObservedObject var appState: AppState
    
    var body: some View {
        DatePicker("Pick a date", selection: $viewModel.dateToAdd, in: Date()..., displayedComponents: .date)
            .datePickerStyle(.graphical)
            .navigationTitle(label(.addNewHoliday))
            .onReceive(viewModel.dismissView) { isDismissed in
                if isDismissed {
                    dismiss()
                }
            }
            .alert(isPresented: $viewModel.isShowingAlert) {
                Alert(
                    title: Text(label(.error)),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK")))
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(label(.cancel)) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(label(.add)) { viewModel.addHoliday(to: &doctorData) }
                }
            }
    }
}

struct AddHoliday_Previews: PreviewProvider {
    static var previews: some View {
        AddHoliday(doctorData: .constant(Doctor.example), viewModel: .init(), appState: .shared)
    }
}
