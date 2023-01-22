//
//  Service.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 01.04.2021.
//

import Foundation

struct Service: Codable {
    var serviceID: UUID
    var name: String
    var price: Int
    var isActive: Bool
}


extension Service: Identifiable {
    var id: UUID {
        serviceID
    }
}


class Services: Codable, ObservableObject {
    
    init() {
        services = [Service]()
    }
    
    static let example = Service(serviceID: UUID(), name: "ServiceExample", price: 50, isActive: true)
    
    var services: [Service]
    
    func load() async throws -> [Service] {
        try await ApiHandler.request(.GET, at: "/services", body: self)
    }
}
