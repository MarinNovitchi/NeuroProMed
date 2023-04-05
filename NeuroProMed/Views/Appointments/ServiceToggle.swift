//
//  ServiceToggle.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 05.04.2021.
//

import SwiftUI

struct ServiceToggle: View {
    
    @Binding var appointment: Appointment.AppointmentProperties
    let service: Service
    
    @State private var isOn = false
    
    func serviceToggleSet(newValue: Bool) {
        isOn = newValue
        if isOn {
            appointment.services.append(AppointmentService(serviceID: service.serviceID, name: service.name, price: service.price))
        } else {
            appointment.services.removeAll(where: { $0.serviceID == service.serviceID })
        }
    }
    
    var body: some View {
        Toggle(isOn: Binding<Bool>(
                get:{ isOn },
                set: serviceToggleSet
            )) {
            HStack {
                Text(service.name)
                    .foregroundColor(.primary)
                Text("\(service.price) lei")
                    .foregroundColor(.secondary)
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
        .onAppear(perform: { isOn = appointment.services.contains { $0.serviceID == service.serviceID} })
    }
}

struct ServiceToggle_Previews: PreviewProvider {
    static var previews: some View {
        ServiceToggle(appointment: .constant(Appointment.example), service: Services.example)
    }
}
