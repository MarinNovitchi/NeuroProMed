//
//  MainViewModel.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 30.03.2023.
//

import Foundation
import SwiftUI

extension MainView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        let appState: AppState
        
        init(appState: AppState = .shared) {
            self.appState = appState
        }
        
        @Published var selectedTab = 0
        
        @Published var alertMessage = ""
        @Published var activeAlert: ActiveAlert?
        
        var isUserDoctor: Bool {
            appState.isUserDoctor
        }
        
        func loadData() async {
            let generator = UINotificationFeedbackGenerator()
            do {
                try await appState.loadData()
            } catch let error as AppError  {
                error.trigger(with: generator, &activeAlert, message: &alertMessage)
            } catch {
                let error = AppError.unknown
                error.trigger(with: generator, &activeAlert, message: &alertMessage)
            }
        }
    }
}
