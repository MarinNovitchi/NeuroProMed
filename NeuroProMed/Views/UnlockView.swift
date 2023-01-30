//
//  UnlockView.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 13.06.2021.
//

import SwiftUI

extension UnlockView {
    
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var isRetryButtonDisplayed = false
        @Published var alertMessage = ""
        @Published var activeAlert: ActiveAlert?
        
        func authenticate() {
            let biometrics = BiometricsHelper()
            if biometrics.isDeviceUnsupportedOrPermissionDenied() {
                activeAlert = .settingsIssue
                alertMessage = label(.biometricsPermissionRequest)
            } else {
                biometrics.authenticate { isEnabled in
                    self.appState.isUnlocked = isEnabled
                    self.isRetryButtonDisplayed = !isEnabled
                }
            }
        }
    }
}

struct UnlockView: View {
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            Image("neuropromed_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 400)
                .blur(radius: 13.0)
            VStack {
                Spacer()
                if viewModel.isRetryButtonDisplayed {
                    Button(label(.retryAuthentication), action: viewModel.authenticate)
                }
            }
        }
        .padding(50)
        .onAppear(perform: viewModel.authenticate)
    }
}

struct UnlockView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockView(viewModel: .init())
    }
}
