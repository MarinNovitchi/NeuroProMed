//
//  LoginView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 01.06.2021.
//

import Security
import SwiftUI

struct LoginView: View {

    @State private var doctorID = ""
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                SplashScreen()
                LoginDoctorOption(doctorID: $doctorID, appState: .shared)
                SignInButton(doctorID: $doctorID, viewModel: .init(), appState: .shared)
                Spacer()
            }
            Spacer()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

