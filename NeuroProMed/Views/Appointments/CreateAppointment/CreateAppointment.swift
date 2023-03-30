//
//  CreateAppointment.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 04.04.2021.
//

import Combine
import SwiftUI

struct CreateAppointment: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ViewModel
    @ObservedObject var appState: AppState
    @Binding var appointmentData: Appointment.AppointmentProperties
    
    var body: some View {
        Form {
            AppointmentFormGroup(
                appointmentData: $appointmentData,
                notificationSchedule: $viewModel.notificationSchedule,
                selectedCalendar: $viewModel.selectedCalendar,
                isUsedByFilter: false,
                appState: appState
            )
        }
        .onReceive(viewModel.dismissView) { isDismissed in
            if isDismissed {
                dismiss()
            }
        }
        .navigationTitle(label(.createAppointment))
        .navigationBarItems(
            leading: Button(label(.cancel)) { dismiss() },
            trailing: Button(label(.save)) {
                viewModel.createAppointment(using: appointmentData)
            }
            .disabled(!viewModel.isAppointmentValid(appointmentData))
        )
        .alert(isPresented: $viewModel.isShowingAlert) {
            Alert(title: Text(label(.error)), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }

    }
}

struct CreateAppointments_Previews: PreviewProvider {
    static var previews: some View {
        CreateAppointment(
            viewModel: .init(),
            appState: .shared,
            appointmentData: .constant(Appointment.example))
    }
}
