//
//  PatientDeleteButton.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 05.04.2021.
//

import SwiftUI

struct PatientDeleteButton: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var appointments: Appointments
    @ObservedObject var patients: Patients
    
    @ObservedObject var patient: Patient
    
    @State private var alertMessage = ""
    @State var activeAlert: ActiveAlert?
    
    func deletePatient() {
        patient.delete() { response in
            switch response {
            case .success:
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                patients.patients.removeAll(where: { $0.patientID == patient.patientID })
                appointments.appointments.removeAll(where: { $0.patientID == patient.patientID } )
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                alertMessage = error.getMessage()
                activeAlert = .error
            }
        }
    }
    
    var body: some View {
        DeleteButton(activeAlert: $activeAlert, title: label(.deletePatient))
            .alert(item: $activeAlert) { item in
                switch item {
                    case .warning:
                        return Alert(title: Text(label(.areYouSure_patient)), message: Text(String(format: label(.deletePatientMessage), patient.title)), primaryButton: .destructive(Text(label(.delete)), action: deletePatient), secondaryButton: .cancel())
                case .error:
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                    return Alert(title: Text(label(.error)), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                case .settingsIssue:
                    return Alert(title: Text(label(.error)), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
    }
}

struct PatientDeleteButton_Previews: PreviewProvider {
    static var previews: some View {
        PatientDeleteButton(appointments: Appointments(), patients: Patients(), patient: Patient(using: Patient.example))
    }
}
