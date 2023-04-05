//
//  ApiHandler.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.03.2021.
//

import Foundation
import SwiftUI

/// struct used to call the API
struct ApiHandler {
    
    private static let baseURL = "https://neuropromed.com"//"http: //192.168.100.4:8081"
    
    /// Creates an API request
    /// - Parameters:
    ///   - type: HTTP request type (e.g. GET, POST)
    ///   - endpoint: API endpoint
    ///   - body: Request body (for POST request type)
    ///   - completion: Action to be performed once the response is received
    static func request<T: Codable, G: Codable>(_ type: HttpRequestType, at endpoint: String, body: T) async throws -> G {
        var request = try newURLRequest(of: type, at: endpoint)
        if type == .POST {
            try append(body, to: &request)
        }
        return try await sendRequest(request)
    }
    
    /// Creates a URL request containing the URL itself and the request type
    /// - Parameters:
    ///   - type: HTTP request type (e.g. GET, POST)
    ///   - endpoint: API endpoint
    /// - Returns: URLRequest object
    private static func newURLRequest(of type: HttpRequestType, at endpoint: String) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else {
            throw AppError.badURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        return request
    }
    
    /// Add a body to the URL request
    /// - Parameters:
    ///   - body: Body to be added
    ///   - request: URLRequest object
    /// - Returns: A boolean value indicating whether the body was successfully appended to the URL request
    private static func append<T: Codable>(_ body: T, to request: inout URLRequest) throws {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let encoded = try? JSONEncoder().encode(body.self) else {
            throw AppError.encodingIssue("Could not encode \(type(of: T.self))")
        }
        request.httpBody = encoded
    }
    
    /// Checks if the
    /// - Parameters:
    ///   - data: Data received from the server
    ///   - completion: Action to be performed after confirming the presence of an error
    /// - Returns: A boolean value indicating whether an error was received or not
    private static func checkForServerError<G: Codable>(data: Data, completion: @escaping (Result<G, AppError>) -> Void) -> Bool {
        var isErrorPresent = false
        if let apiResponse = try? JSONDecoder().decode(ApiResponse.self, from: data) {
            if apiResponse.error {
                isErrorPresent = true
                completion(.failure(.serverError(apiResponse.message ?? "Unknown error")))
            }
        }
        return isErrorPresent
    }
    
    private static func sendRequest<T>(_ request: URLRequest) async throws -> T where T: Codable {

        let (data, response) = try await URLSession.shared.data(for: request)
        if
            let networkResponse = response as? HTTPURLResponse,
            networkResponse.statusCode > 399 {
            throw AppError.serverError("Error \(networkResponse.statusCode): \(networkResponse.description)")
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw AppError.decodingIssue("Could not decode \(type(of: T.self))")
        }
    }
}

enum HttpRequestType: String {
    case GET, POST, DELETE
}

/// Network error types
enum AppError: Error {
    
    case unknown, badURL, encodingIssue(String), decodingIssue(String), requestFailed, serverError(String), conflictingAppointment(String)
    
    /// Provides a network error message
    /// - Returns: Error message
    func getMessage() -> String {
        switch self {
        case .badURL:
            return NSLocalizedString("badURL", comment: "Bad URL error message")
        case .decodingIssue:
            return NSLocalizedString("decodingIssue", comment: "Decoding issue error message")
        case .encodingIssue:
            return NSLocalizedString("ecodingIssue", comment: "Ecoding issue error message")
        case .requestFailed:
            return NSLocalizedString("requestFailed", comment: "Ecoding issue error message")
        case .serverError(let message):
            return message
        case .unknown:
            return NSLocalizedString("unknownError", comment: "Unknown error message")
        case .conflictingAppointment(let message):
            return message
        }
    }
    
    /// Trigger the alert when a network error is encountered
    /// - Parameters:
    ///   - generator: UINotificationFeedbackGenerator for the haptic response
    ///   - alert: Boolean value to trigger the alert
    ///   - message: Alert message to be populated with the error message
    func trigger(with generator: UINotificationFeedbackGenerator, _ alert: inout Bool, message: inout String) {
        generator.notificationOccurred(.error)
        alert = true
        message = getMessage()
    }
    
    /// Trigger the alert when a network error is encountered
    /// - Parameters:
    ///   - generator: UINotificationFeedbackGenerator for the haptic response
    ///   - alert: ActiveAlert object to trigger the alert
    ///   - message: Alert message to be populated with the error message
    func trigger(with generator: UINotificationFeedbackGenerator, _ alert: inout ActiveAlert?, message: inout String) {
        generator.notificationOccurred(.error)
        alert = .error
        message = getMessage()
    }
}

/// API response
struct ApiResponse: Codable {
    var error: Bool
    var message: String?
}

enum ActiveAlert: Identifiable {
    case warning, error, settingsIssue
    var id: Int {
        hashValue
    }
}
