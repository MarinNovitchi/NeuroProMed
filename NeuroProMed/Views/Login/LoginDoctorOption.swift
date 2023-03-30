//
//  LoginDoctorOption.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 19.06.2021.
//

import SwiftUI

struct LoginDoctorOption: View {

    @Binding var doctorID: String
    @ObservedObject var appState: AppState
    
    var body: some View {
        Group {
            Button {
                withAnimation {
                    appState.isUserDoctor.toggle()
                }
            } label: {
                Text(appState.isUserDoctor ? label(.loginAsPatient) : label(.loginAsDoctor))
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 15)
            }
            if appState.isUserDoctor {
                TextField("Doctor ID", text: $doctorID)
                    .padding([.leading, .bottom, .trailing], 15)
                    .transition(.move(edge: .leading))
            }
        }
    }
}

struct LoginDoctorOption_Previews: PreviewProvider {
    static var previews: some View {
        LoginDoctorOption(doctorID: .constant("id"), appState: .shared)
    }
}
