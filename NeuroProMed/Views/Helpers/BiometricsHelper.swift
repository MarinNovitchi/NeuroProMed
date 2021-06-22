//
//  BiometricsHelper.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 29.05.2021.
//

import Foundation
import LocalAuthentication

/// Manage biometrics support and authentication
struct BiometricsHelper {
    
    private let context = LAContext()
    
    /// Check if the device supports biometric authentication
    /// - Returns: A boolean value indicating whether the device supports biometric authentication
    func isDeviceUnsupportedOrPermissionDenied() -> Bool {
        var error: NSError?
        return !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    /// Attempt to authenticate using biometrics
    /// - Parameter completion: Action to be executed once the authentication is performed
    func authenticate(completion: @escaping (Bool) -> Void) {
        if isDeviceUnsupportedOrPermissionDenied() {
            completion(false)
        } else {
            performAuthentication(completion: completion)
        }
    }
    
    /// Attempt to authenticate using biometrics
    /// - Parameter completion: Action to be executed once the authentication is performed
    private func performAuthentication(completion: @escaping (Bool) -> Void) {
        let reason = NSLocalizedString("biometricsRequestReason", comment: "provide the purpose of using biometrics")
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    

}
