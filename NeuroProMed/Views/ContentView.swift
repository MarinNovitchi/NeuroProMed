//
//  ContentView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.03.2021.
//

import LocalAuthentication
import Security
import SwiftUI

extension ContentView {
    
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

struct ContentView: View {
    
    @StateObject var viewModel: ViewModel
    @StateObject var appState: AppState
    
    init(viewModel: ViewModel = ViewModel(), appState: AppState = .shared) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _appState = StateObject(wrappedValue: appState)
    }
    
    var body: some View { 
        ZStack {
            if viewModel.isAuthenticated {
                if viewModel.isUnlocked {
                    MainView(viewModel: .init(), appState: appState)
                } else {
                    UnlockView(viewModel: .init())
                }
            } else {
                VStack {
                    LoginView()
                    Button("Developer unlock: PATIENT") {
                        appState.userID = UUID(uuidString: "BFF5ABB3-1AA4-4821-89E7-68DF30D5B98D")!
                        appState.isAuthenticated = true
                    }
                    Button("Developer unlock: DOCTOR") {
                        appState.userID = UUID(uuidString: "9B1DEB4D-3B7D-4BAD-9BDD-2B0D7B3DCB69")!
                        appState.isUserDoctor = true
                        appState.isAuthenticated = true
                    }
                }
            }
        }
        .onAppear(perform: viewModel.loadView)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
