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
                LoginView(isAuthenticated: $isAuthenticated, isUserDoctor: $isUserDoctor, userID: $userID)
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
