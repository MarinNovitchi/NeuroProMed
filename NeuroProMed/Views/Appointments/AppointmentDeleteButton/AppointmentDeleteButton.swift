//
//  AppointmentDeleteButton.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 24.04.2021.
//

import SwiftUI

struct AppointmentDeleteButton: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appointment: Appointment
    @StateObject var viewModel: ViewModel
    @ObservedObject var appState: AppState
    
    var body: some View {
        DeleteButton(activeAlert: $viewModel.activeAlert, title: label(.cancelAppointment) )
            .alert(item: $viewModel.activeAlert) { item in
                switch item {
                case .warning:
                    return Alert(title: Text(label(.areYouSure_appointment)),
                                 message: Text(label(.deleteAppointmentMessage)),
                                 primaryButton: .destructive(Text(label(.delete)), action: { viewModel.delete(appointment: appointment) }),
                                 secondaryButton: .cancel())
                case .error:
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                    return Alert(title: Text(label(.error)), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                case .settingsIssue:
                    return Alert(title: Text(label(.error)), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                }
            }
            .onReceive(viewModel.dismissView) { isDismissed in
                if isDismissed {
                    dismiss()
                }
            }
    }
}

struct AppointmentDeleteButton_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentDeleteButton(appointment: Appointment(using: Appointment.example), viewModel: .init(), appState: .shared)
    }
}
