//
//  Doctor.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 31.03.2021.
//

import Foundation


class Doctor: Codable, Identifiable, ObservableObject  {
    
    init(doctorID: UUID, firstName: String, lastName: String, email: String?, isDoctor: Bool, isWorkingWeekends: Bool, specialty: String, unavailability: [Date]) {
        self.doctorID = doctorID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.isDoctor = isDoctor
        self.isWorkingWeekends = isWorkingWeekends
        self.specialty = specialty
        self.unavailability = unavailability
    }
    
    required init(from decoder: Decoder) throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        doctorID = try container.decode(UUID.self, forKey: .doctorID)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        email = try container.decode(String?.self, forKey: .email)
        isDoctor = try container.decode(Bool.self, forKey: .isDoctor)
        isWorkingWeekends = try container.decode(Bool.self, forKey: .isWorkingWeekends)
        specialty = try container.decode(String.self, forKey: .specialty)
        let stringDates = try container.decode([String].self, forKey: .unavailability)
        unavailability = stringDates.map{ formatter.date(from: $0)?.setToMidDayGMT() ?? Date() }
    }
    
    var doctorID: UUID
    @Published var firstName: String
    @Published var lastName: String
    @Published var email: String?
    var isDoctor: Bool
    @Published var isWorkingWeekends: Bool
    @Published var specialty: String
    @Published var unavailability: [Date]
    
    var title: String {
        "Dr. \(firstName) \(lastName)"
    }
    
    func encode(to encoder: Encoder) throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(doctorID, forKey: .doctorID)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encode(isDoctor, forKey: .isDoctor)
        try container.encode(isWorkingWeekends, forKey: .isWorkingWeekends)
        try container.encode(specialty, forKey: .specialty)
        let unavailableDates = unavailability.map{ formatter.string(from: $0) }
        try container.encode(unavailableDates, forKey: .unavailability)
    }
    
    enum CodingKeys: CodingKey {
        case doctorID, firstName, lastName, email, isDoctor, isWorkingWeekends, specialty, unavailability
    }
}


extension Doctor {
    struct DoctorProperties: Codable {
        var doctorID = UUID()
        var firstName = ""
        var lastName = ""
        var email = ""
        var isWorkingWeekends = false
        var specialty = ""
        var unavailability = [Date]()
    }
    
    convenience init(using doctorData: DoctorProperties) {
        self.init(doctorID: doctorData.doctorID, firstName: doctorData.firstName, lastName: doctorData.lastName, email: doctorData.email, isDoctor: true, isWorkingWeekends: doctorData.isWorkingWeekends, specialty: doctorData.specialty, unavailability: doctorData.unavailability)
    }
    
    func updateDoctor(using doctorData: DoctorProperties) {
        firstName = doctorData.firstName
        lastName = doctorData.lastName
        email = doctorData.email.isEmpty ? nil : doctorData.email
        isDoctor = true
        isWorkingWeekends = doctorData.isWorkingWeekends
        specialty = doctorData.specialty
        unavailability = doctorData.unavailability
    }
    
    var data: DoctorProperties {
        DoctorProperties(doctorID: doctorID, firstName: firstName, lastName: lastName, email: email ?? "", isWorkingWeekends: isWorkingWeekends, specialty: specialty, unavailability: unavailability)
    }
    
    static let example = DoctorProperties(firstName: "DrFirstName", lastName: "DrLastName", email: "email@example.com", isWorkingWeekends: false, specialty: "Neurologist", unavailability: [Date]())
}


extension Doctor {
    
//    func create(completion: @escaping (Result<ApiResponse, NetworkError>) -> Void) {
//        ApiHandler.request(.POST, at: "/adddoctor", body: self, completion: completion)
//    }
    
    func update(completion: @escaping (Result<ApiResponse, NetworkError>) -> Void) {
        ApiHandler.request(.POST, at: "/editdoctor", body: self, completion: completion)
    }
    
}


class Doctors: ObservableObject {
    
    init() {
        doctors = [Doctor]()
    }
    
    @Published var doctors: [Doctor]
    
    func load(completion: @escaping (Result<[Doctor], NetworkError>) -> Void) {
        ApiHandler.request(.GET, at: "/doctors", body: self.doctors, completion: completion)
    }
    
}
