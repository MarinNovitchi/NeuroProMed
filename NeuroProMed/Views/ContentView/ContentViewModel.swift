//
//  ContentViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Foundation

extension ContentView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        func loadView(){
            retrieveKeyChainValue()
            if !appState.useBiometrics {
                appState.isUnlocked = true
            }
        }
        
        func retrieveKeyChainValue() {
            let keychainHelper = KeychainHelper()
            do {
                let credentials = try keychainHelper.retrieveCredentials()
                appState.userID = credentials.userID
                appState.isUserDoctor = credentials.isDoctor
                appState.useBiometrics = credentials.useBiometrics
                appState.isAuthenticated = true
            } catch {
                print("no keychain values found")
            }
        }
        
        var isAuthenticated: Bool {
            appState.isAuthenticated
        }
        
        var isUnlocked: Bool {
            appState.isUnlocked
        }
    }
}
