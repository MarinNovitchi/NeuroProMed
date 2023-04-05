//
//  Patient.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.03.2021.
//

import Foundation

class Patient: Codable, Comparable, Identifiable, ObservableObject {

    init(firstName: String, lastName: String, birthDate: Date?, phoneNumber: String?, address: String?, job: String?) {
        self.patientID = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.phoneNumber = phoneNumber
        self.address = address
        self.job = job
    }
    
    required init(from decoder: Decoder) throws {
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        patientID = try container.decode(UUID.self, forKey: .patientID)
        firstName = try container.decode(String?.self, forKey: .firstName) ?? NSLocalizedString("unknownFirstName", comment: "Unknown firstName placeholder")
        lastName = try container.decode(String?.self, forKey: .lastName) ?? NSLocalizedString("unknownLastName", comment: "Unknown lastName placeholder")
        let stringDate = try container.decode(String?.self, forKey: .birthDate)
        birthDate = formatter.date(from: stringDate ?? "")
        phoneNumber = try container.decode(String?.self, forKey: .phoneNumber)
        address = try container.decode(String?.self, forKey: .address)
        job = try container.decode(String?.self, forKey: .job)
    }

    let patientID: UUID
    @Published var firstName: String
    @Published var lastName: String
    @Published var birthDate: Date?
    @Published var phoneNumber: String?
    @Published var address: String?
    @Published var job: String?
    
    static func < (lhs: Patient, rhs: Patient) -> Bool {
        if lhs.lastName == rhs.lastName {
            return lhs.firstName < rhs.firstName
        }
        return lhs.lastName < rhs.lastName
    }
    
    static func == (lhs: Patient, rhs: Patient) -> Bool {
        lhs.patientID == rhs.patientID
    }
    
    var title: String {
        "\(firstName) \(lastName)"
    }
    
    var formattedBirthDate: String {
        if let birthDate = birthDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: birthDate)
        } else {
            return NSLocalizedString("unspecified", comment: "Unspecified birth date placeholder")
        }
    }
    
    var age: String {
        if let unwrappedBirthDate = birthDate {
            let components = Calendar.current.dateComponents([.year, .month], from: unwrappedBirthDate, to: Date())
            let ageYears = components.year
            let ageMonths = components.month
            if let ageYears = ageYears, let ageMonths = ageMonths {
                return "\(ageYears) years, \(ageMonths) months"
            } else {
                return NSLocalizedString("unknownAge", comment: "Unknown age placeholder")
            }
        } else {
            return NSLocalizedString("unknownAge", comment: "Unknown age placeholder")
        }
    }
    
    var formattedPhoneNumber: String {
        phoneNumber ?? NSLocalizedString("unknownPhoneNumber", comment: "Unknown phone number placeholder")
    }
    
    var formattedAddress: String {
        address ?? NSLocalizedString("unknownAddress", comment: "Unknown address placeholder")
    }
    
    var formattedJob: String {
        job ?? NSLocalizedString("unknownJob", comment: "Unknown job placeholder")
    }
    
    func getAppointments(from appointments: [Appointment]) -> [Appointment] {
        appointments.filter({ $0.patientID == self.patientID })
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(patientID, forKey: .patientID)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        if let unwrappedBirthDate = birthDate {
            if unwrappedBirthDate.compare(Date().addingTimeInterval(-5000)) == .orderedAscending {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                try container.encode(formatter.string(from: unwrappedBirthDate), forKey: .birthDate)
            }
        }
        try container.encode(phoneNumber?.isEmpty ?? true ? nil : phoneNumber, forKey: .phoneNumber)
        try container.encode(address?.isEmpty ?? true ? nil : address, forKey: .address)
        try container.encode(job?.isEmpty ?? true ? nil : job, forKey: .job)
    }
    
    enum CodingKeys: CodingKey {
        case patientID, firstName, lastName, phoneNumber, birthDate, address, job
    }
}


extension Patient {
    struct PatientProperties: Codable {
        var firstName = ""
        var lastName = ""
        var birthDate = Date()
        var birthDateFrom = Calendar.current.date(byAdding: .year, value: -50, to: Date()) ?? Date()
        var birthDateTo = Date()
        var phoneNumber = ""
        var address = ""
        var job = ""
    }
    
    convenience init(using patientData: PatientProperties) {
        self.init(
            firstName: patientData.firstName.capitalizingFirstLetter(),
            lastName: patientData.lastName.capitalizingFirstLetter(),
            birthDate: patientData.birthDate,
            phoneNumber: patientData.phoneNumber.isEmpty ? nil : patientData.phoneNumber,
            address: patientData.address.isEmpty ? nil : patientData.address,
            job: patientData.job.isEmpty ? nil : patientData.job )
    }
    
    func updatePatient(using patientData: PatientProperties) {
        firstName = patientData.firstName.capitalizingFirstLetter()
        lastName = patientData.lastName.capitalizingFirstLetter()
        birthDate = patientData.birthDate.compare(Date().addingTimeInterval(-5000)) == .orderedAscending ? patientData.birthDate : nil
        phoneNumber = patientData.phoneNumber.isEmpty ? nil : patientData.phoneNumber
        address = patientData.address.isEmpty ? nil : patientData.address
        job = patientData.job.isEmpty ? nil : patientData.job
    }
    
    var data: PatientProperties {
        PatientProperties(
            firstName: firstName,
            lastName: lastName,
            birthDate: birthDate ?? Date(),
            phoneNumber: phoneNumber ?? "",
            address: address ?? "",
            job: job ?? "")
    }
    
    static let example = PatientProperties(
        firstName: "FirstName",
        lastName: "LastName",
        birthDate: Date().addingTimeInterval(-3000000),
        birthDateFrom: Date(),
        birthDateTo: Date(),
        phoneNumber: "072245641",
        address: "ExampleAddress",
        job: "ExampleJob")
}



extension Patient {
    
    func create() async throws -> ApiResponse {
        try await ApiHandler.request(.POST, at: "/addpatient", body: self)
    }
    
    func update() async throws -> ApiResponse {
        try await ApiHandler.request(.POST, at: "/editpatient", body: self)
    }
    
    func delete() async throws -> ApiResponse {
        try await ApiHandler.request(.DELETE, at: "/deletepatient/\(patientID)", body: self)
    }
}



class Patients: ObservableObject {
        
    init() {
        patients = [Patient]()
    }
    
    @Published var patients: [Patient]

    func load() async throws -> [Patient] {
        try await ApiHandler.request(.GET, at: "/patients", body: patients)
    }
    
    func filterPatients(using filterData: Patient.PatientProperties) async throws -> [Patient] {
        try await ApiHandler.request(.POST, at: "/searchpatients", body: filterData)
    }
    
}
