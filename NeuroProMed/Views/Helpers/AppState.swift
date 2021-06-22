//
//  AppState.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 16.05.2021.
//

import Foundation


/// Class with a published selectedAppointmentID to be used when the application is opened via a notification tap and the appointmentView must be shown
class AppState: ObservableObject {
    
    static let shared = AppState()
    @Published var selectedAppointmentID : String?
}
