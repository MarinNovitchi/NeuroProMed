//
//  AddPatientView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.03.2021.
//

import SwiftUI

struct CreatePatient: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var patients: Patients
    
    @State private var patientData = Patient.PatientProperties()
    
    @State private var alertMessage = ""
    @State private var isShowingAlert = false

    func createPatient() {
        let newPatient = Patient(using: patientData)
        newPatient.create() { response in
            let generator = UINotificationFeedbackGenerator()
            switch response {
                case .success:
                    patients.patients.insert(newPatient, at: 0)
                    generator.notificationOccurred(.success)
                    presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                error.trigger(with: generator, &isShowingAlert, message: &alertMessage)
            }
        }
    }
    
    var body: some View {
        Form {
            PatientDetailsSection(patientData: $patientData, isUsedByFilter: false)
        }
        .navigationTitle(label(.createPatient))
        .navigationBarItems(
            leading: Button(label(.cancel)) { presentationMode.wrappedValue.dismiss() },
            trailing: Button(label(.save), action: createPatient)
                .disabled(patientData.firstName.isEmpty || patientData.lastName.isEmpty)
        )
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text(label(.error)), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct AddPatientView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePatient(patients: Patients())
    }
}
