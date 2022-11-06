//
//  ContentView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.03.2021.
//

import LocalAuthentication
import Security
import SwiftUI

struct ContentView: View {
    
    @State private var isAuthenticated = false
    @State private var userID = UUID()
    @State private var isUserDoctor = false
    
    @State private var useBiometrics = false
    @State private var isUnlocked = false
    
    func loadView(){
        retrieveKeyChainValue()
        if !useBiometrics {
            isUnlocked = true
        }
    }
    
    func retrieveKeyChainValue() {
        let keychainHelper = KeychainHelper()
        do {
            let credentials = try keychainHelper.retrieveCredentials()
            userID = credentials.userID
            isUserDoctor = credentials.isDoctor
            useBiometrics = credentials.useBiometrics
            isAuthenticated = true
        } catch {
            print("no keychain values found")
        }
    }
    
    var body: some View { 
        ZStack {
            if isAuthenticated {
                if isUnlocked {
                    MainView(
                        userID: $userID,
                        isUserDoctor: $isUserDoctor,
                        isAuthenticated: $isAuthenticated,
                        useBiometrics: $useBiometrics)
                } else {
                    UnlockView(isUnlocked: $isUnlocked)
                }

            } else {
                VStack {
                    LoginView(isAuthenticated: $isAuthenticated, isUserDoctor: $isUserDoctor, userID: $userID)
                    Button("Developer unlock: PATIENT") {
                        userID = UUID(uuidString: "BFF5ABB3-1AA4-4821-89E7-68DF30D5B98D")!
                        isAuthenticated = true
                    }
                    Button("Developer unlock: DOCTOR") {
                        userID = UUID(uuidString: "9B1DEB4D-3B7D-4BAD-9BDD-2B0D7B3DCB69")!
                        isUserDoctor = true
                        isAuthenticated = true
                    }
                }
            }
        }
        .onAppear(perform: loadView)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
