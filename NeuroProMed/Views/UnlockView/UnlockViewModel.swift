//
//  UnlockViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Foundation

extension UnlockView {
    
    @MainActor
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
