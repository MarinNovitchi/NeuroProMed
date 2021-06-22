//
//  LoginView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 01.06.2021.
//

import Security
import SwiftUI

struct LoginView: View {
    
    @Binding var isAuthenticated: Bool
    @Binding var isUserDoctor: Bool
    @Binding var userID: UUID
    
    @State private var doctorID = ""
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                SplashScreen()
                LoginDoctorOption(isUserDoctor: $isUserDoctor, doctorID: $doctorID)
                SignInButton(
                    isAuthenticated: $isAuthenticated,
                    isUserDoctor: $isUserDoctor,
                    doctorID: $doctorID,
                    userID: $userID)
                Spacer()
            }
            Spacer()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isAuthenticated: .constant(false), isUserDoctor: .constant(false), userID: .constant(UUID()))
    }
}

