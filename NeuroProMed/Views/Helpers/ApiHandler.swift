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
    
    private static let baseURL = "http://192.168.100.4:8081"
    
    /// Creates an API request
    /// - Parameters:
    ///   - type: HTTP request type (e.g. GET, POST)
    ///   - endpoint: API endpoint
    ///   - body: Request body (for POST request type)
    ///   - completion: Action to be performed once the response is received
    static func request<T: Codable, G: Codable>(_ type: HttpRequestType, at endpoint: String, body: T, completion: @escaping (Result<G, NetworkError>) -> Void) {
        //TODO: make the T optional
        
        let potentialRequest = newURLRequest(of: type, at: endpoint)
        guard var request = potentialRequest else {
            completion(.failure(.badURL))
            return
        }
        
        if type == .POST {
            let appended = append(body: body, to: &request)
            guard appended else {
                completion(.failure(.encodingIssue))
                return
            }
        }
        
        send(request, completion: completion)
    }
    
    /// Creates a URL request containing the URL itself and the request type
    /// - Parameters:
    ///   - type: HTTP request type (e.g. GET, POST)
    ///   - endpoint: API endpoint
    /// - Returns: URLRequest object
    private static func newURLRequest(of type: HttpRequestType, at endpoint: String) -> URLRequest? {
        guard let url = URL(string: baseURL + endpoint) else {
            return nil
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
    private static func append<T: Codable>(body: T, to request: inout URLRequest) -> Bool {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let encoded = try? JSONEncoder().encode(body.self) else {
            return false
        }
        request.httpBody = encoded
        return true
    }
    
    /// Checks if the
    /// - Parameters:
    ///   - data: Data received from the server
    ///   - completion: Action to be performed after confirming the presence of an error
    /// - Returns: A boolean value indicating whether an error was received or not
    private static func checkForServerError<G: Codable>(data: Data, completion: @escaping (Result<G, NetworkError>) -> Void) -> Bool {
        var isErrorPresent = false
        if let apiResponse = try? JSONDecoder().decode(ApiResponse.self, from: data) {
            if apiResponse.error {
                isErrorPresent = true
                completion(.failure(.serverError(apiResponse.message ?? "Unknown error")))
            }
        }
        return isErrorPresent
    }
    
    /// Send the URL request to the server
    /// - Parameters:
    ///   - request: URLRequest object
    ///   - completion: Action to be performed after confirming the presence of an error
    private static func send<G: Codable>(_ request: URLRequest, completion: @escaping (Result<G, NetworkError>) -> Void) {
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {

                    let isErrorPresent = checkForServerError(data: data, completion: completion)
                    
                    if !isErrorPresent {
                        if let decodedResponse = try? JSONDecoder().decode(G.self, from: data) {
                            completion(.success(decodedResponse))
                        } else {
                            completion(.failure(.decodingIssue))
                        }
                    }
                    
                } else if error != nil {
                    completion(.failure(.requestFailed))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }.resume()
    }
}

enum HttpRequestType: String {
    case GET, POST, DELETE
}

/// Network error types
enum NetworkError: Error {
    
    case unknown, badURL, encodingIssue, decodingIssue, requestFailed, serverError(String)
    
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
