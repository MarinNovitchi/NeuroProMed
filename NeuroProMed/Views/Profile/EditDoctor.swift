//
//  EditDoctor.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 17.05.2021.
//

import SwiftUI

extension EditDoctor {
    
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var isAddHolidaySheetPresented = false
        @Published var temporaryBiometricsSettings = false
        
        @Published var alertMessage = ""
        @Published var isShowingAlert = false
        
        func saveChanges(from doctoData: Doctor.DoctorProperties, to doctor: Doctor) {
            doctor.updateDoctor(using: doctoData)
    //        doctor.update() { response in
    //            let generator = UINotificationFeedbackGenerator()
    //            switch response {
    //            case .success:
    //                generator.notificationOccurred(.success)
    //                saveBiometricsSetting()
    //                presentationMode.wrappedValue.dismiss()
    //            case .failure(let error):
    //                error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
    //            }
    //        }
        }
        
        func saveBiometricsSetting(for doctorID: UUID) {
            let keychainHelper = KeychainHelper()
            let credentials = KeychainCredentials(userID: doctorID, isDoctor: true, useBiometrics: temporaryBiometricsSettings)
            do {
                try keychainHelper.updateCredentials(credentials: credentials)
                AppState.shared.useBiometrics = temporaryBiometricsSettings
            } catch {
                alertMessage = label(.failToUpdateSettings)
                isShowingAlert = true
            }
        }
        
        func assignBiometricsSettings() {
            temporaryBiometricsSettings = appState.useBiometrics
        }
    }
}

struct EditDoctor: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: ViewModel
    @ObservedObject var doctor: Doctor
    @Binding var doctorData: Doctor.DoctorProperties
    
    var body: some View {
        Form {
            Group {
                CustomSection(header: Text(label(.doctorDetails))) {
                    TextField(label(.firstName), text: $doctorData.firstName)
                    TextField(label(.lastName), text: $doctorData.lastName)
                    TextField(label(.email), text: $doctorData.email)
                    Toggle(isOn: $doctorData.isWorkingWeekends) {
                        Text(label(.workingWeekends))
                    }
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                    TextField(label(.specialty), text: $doctorData.specialty)
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
                                            AddHoliday(viewModel: .init(doctorData: doctorData))
                                        }
                                    }
                }
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
            .alert(isPresented: $viewModel.isShowingAlert) {
                Alert(title: Text(label(.error)), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct EditDoctor_Previews: PreviewProvider {
    static var previews: some View {
        EditDoctor(
            viewModel: .init(),
            doctor: Doctor(using: Doctor.example),
            doctorData: .constant(Doctor.example))
    }
}
