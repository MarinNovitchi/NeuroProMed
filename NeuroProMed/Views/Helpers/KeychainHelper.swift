//
//  KeychainHelper.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 13.06.2021.
//

import Foundation

struct KeychainCredentials {
    let userID: UUID
    let isDoctor: Bool
    let useBiometrics: Bool
}

/// Manages keychain CRUD operations
class KeychainHelper {
    
    /// Keychain errors
    enum KeychainError: Error {
        case encodingIssue
        case noPassword
        case unexpectedPasswordData
        case unhandledError(status: OSStatus)
    }
    
    private var query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                        kSecAttrDescription as String: "Neuropromed account",
                                        kSecAttrService as String: "com.novitchi.NeuroProMed"]
    
    
    /// Save credentials in Keychain
    /// - Parameters:
    ///   - userID: the ID of the user
    ///   - isDoctor: A boolean value indicating whether the current user is logged in as a doctor or a patient
    /// - Throws: A KeychainError value if the save was unsuccessful
    func saveCredentials(userID: UUID, isDoctor: Bool) throws {
        let concatenatedAuth = "\(userID.uuidString)|\(isDoctor)|false" //initial save has useBiometrics set on false by default
        guard let encodedUserID = concatenatedAuth.data(using: String.Encoding.utf8) else { throw KeychainError.encodingIssue }

        query[kSecAttrGeneric as String] = encodedUserID
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }
    
    /// Retrieve the Keychain credentials
    /// - Throws: A KeychainError value if no credentials were found
    /// - Returns: The Keychain credentials
    func retrieveCredentials() throws -> KeychainCredentials {
        
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = true
        query[kSecReturnData as String] = true
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        
        guard let existingItem = item as? [String : Any],
            let encodedAuth = existingItem[kSecAttrGeneric as String] as? Data,
            let decodedAuth = String(data: encodedAuth, encoding: String.Encoding.utf8),
            let decodedUserID = UUID(uuidString: decodedAuth.components(separatedBy: "|")[0]),
            let unwrappedIsDoctor = Bool(decodedAuth.components(separatedBy: "|")[1]),
            let unwrappedUseBiometrics = Bool(decodedAuth.components(separatedBy: "|")[2])
        else {
            throw KeychainError.unexpectedPasswordData
        }
        return KeychainCredentials(userID: decodedUserID, isDoctor: unwrappedIsDoctor, useBiometrics: unwrappedUseBiometrics)
    }
    
    /// Update the Keychain credentials
    /// - Parameter credentials: The up to date credentials to be saved
    /// - Throws: A KeychainError value if the save was unsuccesful
    func updateCredentials(credentials: KeychainCredentials) throws {

        let concatenatedAuth = "\(credentials.userID.uuidString)|\(credentials.isDoctor)|\(credentials.useBiometrics)"
        guard let encodedUserID = concatenatedAuth.data(using: String.Encoding.utf8) else { throw KeychainError.encodingIssue }
        let newquery: [String: Any] = [kSecAttrGeneric as String: encodedUserID]
        
        let status = SecItemUpdate(query as CFDictionary, newquery as CFDictionary) 
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }
    
    /// Delete the Keychain credentials
    /// - Throws: A KeychainError value if the deletion was unsuccesful
    func deleteCredentials() throws {
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
}
