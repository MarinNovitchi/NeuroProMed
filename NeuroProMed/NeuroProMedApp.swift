//
//  NeuroProMedApp.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.03.2021.
//

import AuthenticationServices
import Security
import SwiftUI


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        DispatchQueue.main.async {
            AppState.shared.selectedAppointmentID = response.notification.request.identifier
        }
        completionHandler()
    }
}

@main
struct NeuroProMedApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: .init(), appState: .shared)
        }
    }
}
