//
//  AppointmentService.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 02.04.2023.
//

import Foundation

struct AppointmentService: Codable, Identifiable {
    let serviceID: UUID
    let name: String
    var price: Int
    
    var id: UUID {
        serviceID
    }
}
