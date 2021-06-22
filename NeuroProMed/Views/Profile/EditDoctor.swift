//
//  EditDoctor.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 17.05.2021.
//

import SwiftUI

struct EditDoctor: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var appointments: Appointments
    
    @ObservedObject var doctor: Doctor
    
    @Binding var doctorData: Doctor.DoctorProperties
    @Binding var useBiometrics: Bool
    
    @State private var isAddHolidaySheetPresented = false
    @State private var temporaryBiometricsSettings = false
    
    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    
    func saveChanges() {
        doctor.updateDoctor(using: doctorData)
        doctor.update() { response in
            let generator = UINotificationFeedbackGenerator()
            switch response {
            case .success:
                generator.notificationOccurred(.success)
                saveBiometricsSetting()
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
            }
        }
    }
    
    func saveBiometricsSetting() {
        let keychainHelper = KeychainHelper()
        let credentials = KeychainCredentials(userID: doctor.doctorID, isDoctor: true, useBiometrics: temporaryBiometricsSettings)
        do {
            try keychainHelper.updateCredentials(credentials: credentials)
            useBiometrics = temporaryBiometricsSettings
        } catch {
            alertMessage = label(.failToUpdateSettings)
            isShowingAlert = true
        }
        
    }
    
    var body: some View {
        Form {
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
                                        HolidaySection(doctorData: $doctorData, isSectionEditable: true)
                                    }
                                }
                                .navigationTitle(label(.holidays))
                                .navigationBarItems(trailing: Button(label(.add)) { isAddHolidaySheetPresented = true }))
                                .sheet(isPresented: $isAddHolidaySheetPresented) {
                                    NavigationView {
                                        AddHoliday(appointments: appointments, doctorData: $doctorData)
                                    }
                                }
            }
            BiometricsSettingsView(useBiometrics: $temporaryBiometricsSettings)
        }
        .navigationTitle(label(.editDoctor))
        .navigationBarItems(
            leading: Button(label(.cancel)) { presentationMode.wrappedValue.dismiss() },
            trailing: Button(label(.save), action: saveChanges)
                .disabled(doctorData.firstName.isEmpty || doctorData.lastName.isEmpty)
        )
        .onAppear(perform: { temporaryBiometricsSettings = useBiometrics })
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text(label(.error)), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct EditDoctor_Previews: PreviewProvider {
    static var previews: some View {
        EditDoctor(
            appointments: Appointments(),
            doctor: Doctor(using: Doctor.example),
            doctorData: .constant(Doctor.example),
            useBiometrics: .constant(false))
    }
}
