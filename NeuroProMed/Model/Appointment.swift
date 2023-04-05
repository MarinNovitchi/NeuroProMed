//
//  Appointment.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 21.03.2021.
//

import Foundation

class Appointment: Codable, Comparable, Identifiable, ObservableObject {
        
    init(appointmentDate: Date, doctorID: UUID, patientID: UUID, services: [AppointmentService]) {
        self.appointmentID = UUID()
        self.appointmentDate = appointmentDate
        self.doctorID = doctorID
        self.patientID = patientID
        self.appointmentServices = services
    }
    
    required init(from decoder: Decoder) throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let container = try decoder.container(keyedBy: CodingKeys.self)
        appointmentID = try container.decode(UUID.self, forKey: .appointmentID)
        let stringDate = try container.decode(String.self, forKey: .appointmentDate)
        appointmentDate = formatter.date(from: stringDate) ?? Date()
        doctorID = try container.decode(UUID.self, forKey: .doctorID)
        patientID = try container.decode(UUID.self, forKey: .patientID)
        appointmentServices = try container.decode([AppointmentService].self, forKey: .services)
    }
    
    let appointmentID: UUID
    @Published var appointmentDate: Date
    @Published var doctorID: UUID
    let patientID: UUID
    private var services = [UUID]()
    @Published var appointmentServices: [AppointmentService] {
        didSet {
            services = appointmentServices.map { $0.serviceID }
        }
    }
    
    static func < (lhs: Appointment, rhs: Appointment) -> Bool {
        lhs.appointmentDate.compare(rhs.appointmentDate) == .orderedDescending
    }
    static func == (lhs: Appointment, rhs: Appointment) -> Bool {
        lhs.appointmentDate.compare(rhs.appointmentDate) == .orderedSame
    }
    
    var formattedAppointmentDate: String {
        if Calendar.current.isDateInToday(appointmentDate) {
            return NSLocalizedString("today", comment: "Today")
        }
        if Calendar.current.isDateInTomorrow(appointmentDate) {
            return NSLocalizedString("tomorrow", comment: "Tomorrow")
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: appointmentDate)
    }
    
    func encode(to encoder: Encoder) throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(appointmentID, forKey: .appointmentID)
        try container.encode(formatter.string(from: appointmentDate), forKey: .appointmentDate)
        try container.encode(doctorID, forKey: .doctorID)
        try container.encode(patientID, forKey: .patientID)
        try container.encode(services, forKey: .services)
    }
    
    enum CodingKeys: CodingKey {
        case appointmentID, appointmentDate, doctorID, patientID, services
    }
    
}


extension Appointment {
    struct AppointmentProperties: Codable {
        var appointmentDate: Date?
        var appointmentDateFrom = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        var appointmentDateTo = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
        var doctorID: UUID?
        var patientID: UUID?
        var services = [AppointmentService]()
    }
    
    convenience init(using appointmentData: AppointmentProperties) {
        self.init(appointmentDate: appointmentData.appointmentDate ?? Date(), doctorID: appointmentData.doctorID ?? UUID(), patientID: appointmentData.patientID ?? UUID(), services: appointmentData.services)
    }
    
    func updateAppointment(using appointmentData: AppointmentProperties, currentServices: [Service]) {
        if let unwrappedDate = appointmentData.appointmentDate, let unwrappedDoctorID = appointmentData.doctorID {
            appointmentDate = unwrappedDate
            doctorID = unwrappedDoctorID
        }
        let updatedAppointmentServices = appointmentData.services.map { appointmentService in
            if let foundService = currentServices.first(where: { $0.serviceID == appointmentService.serviceID}) {
                return AppointmentService(
                    serviceID: appointmentService.serviceID,
                    name: appointmentService.name,
                    price: foundService.price)
            }
            return appointmentService
        }
        appointmentServices = updatedAppointmentServices
    }
    
    var data: AppointmentProperties {
        AppointmentProperties(appointmentDate: appointmentDate, doctorID: doctorID, patientID: patientID, services: appointmentServices)
    }
    
    static let example = AppointmentProperties(appointmentDate: Date(), appointmentDateFrom: Date().addingTimeInterval(-400000), appointmentDateTo: Date().addingTimeInterval(40000), doctorID: UUID(), patientID: nil, services: [AppointmentService]())
}


extension Appointment {
    func create() async throws -> ApiResponse {
        try await ApiHandler.request(.POST, at: "/createappointment", body: self)
    }
    
    func update() async throws -> ApiResponse {
        try await ApiHandler.request(.POST, at: "/editappointment", body: self)
    }
    
    func delete() async throws -> ApiResponse {
        try await ApiHandler.request(.DELETE, at: "/deleteappointment/\(appointmentID)", body: self)
    }
}


class Appointments: ObservableObject {
    
    init() {
        appointments = [Appointment]()
    }
    
    @Published var appointments: [Appointment]

    
    func load() async throws -> [Appointment] {
        try await ApiHandler.request(.GET, at: "/appointments", body: appointments)
    }
    
    func filterAppointments(using filterData: Appointment.AppointmentProperties) async throws -> [Appointment] {
        try await ApiHandler.request(.POST, at: "/searchappointments", body: filterData)
    }
}
