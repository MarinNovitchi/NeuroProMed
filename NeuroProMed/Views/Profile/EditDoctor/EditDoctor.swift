//
//  EditDoctor.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 17.05.2021.
//

import SwiftUI

struct EditDoctor: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: ViewModel
    @ObservedObject var doctor: Doctor
    @Binding var doctorData: Doctor.DoctorProperties
    @ObservedObject var appState: AppState
    
    var doctorDetailsView: some View {
        CustomSection(header: Text(label(.doctorDetails))) {
            TextField(label(.firstName), text: $doctorData.firstName)
            TextField(label(.lastName), text: $doctorData.lastName)
            TextField(label(.email), text: $doctorData.email)
            Toggle(isOn: $doctorData.isWorkingWeekends) {
                Text(label(.workingWeekends))
            }
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
            TextField(label(.specialty), text: $doctorData.specialty)
            holidayAmountView
        }
    }
    
    var holidayAmountView: some View {
        NavigationLink(String(format: label(.holidayAmount), doctorData.unavailability.count), destination:
                        List {
                            if doctorData.unavailability.count > 0 {
                                HolidaySection(viewModel: .init(), doctorData: $doctorData, isSectionEditable: true)
                            }
                        }
                        .navigationTitle(label(.holidays))
                        .navigationBarItems(trailing: Button(label(.add)) { viewModel.isAddHolidaySheetPresented = true }))
                        .sheet(isPresented: $viewModel.isAddHolidaySheetPresented) {
                            NavigationView {
                                AddHoliday(doctorData: $doctorData, viewModel: .init(), appState: appState)
                            }
                        }
    }
    
    var body: some View {
        Form {
            doctorDetailsView
            BiometricsSettingsView(useBiometrics: $viewModel.temporaryBiometricsSettings)
        }
        .navigationTitle(label(.editDoctor))
        .navigationBarItems(
            leading: Button(label(.cancel)) { dismiss() },
            trailing: Button(label(.save)) {
                viewModel.saveChanges(from: doctorData, to: doctor)
            }
            .disabled(doctorData.firstName.isEmpty || doctorData.lastName.isEmpty)
        )
        .onAppear(perform: { viewModel.assignBiometricsSettings() })
        .onReceive(viewModel.dismissView) { isDismissed in
            if isDismissed {
                dismiss()
            }
        }
        .alert(isPresented: $viewModel.isShowingAlert) {
            Alert(title: Text(label(.error)), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct EditDoctor_Previews: PreviewProvider {
    static var previews: some View {
        EditDoctor(
            viewModel: .init(),
            doctor: Doctor(using: Doctor.example),
            doctorData: .constant(Doctor.example),
            appState: .shared)
    }
}
