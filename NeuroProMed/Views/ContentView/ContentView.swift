//
//  ContentView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.03.2021.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel: ViewModel
    @StateObject var appState: AppState
    
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
        .onAppear { viewModel.loadView() }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init(), appState: .shared)
    }
}
