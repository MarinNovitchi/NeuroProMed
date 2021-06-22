//
//  KeychainHelperTests.swift
//  NeuroProMedTests
//
//  Created by Marin Novitchi on 22.06.2021.
//

import XCTest

@testable import NeuroProMed

/// Tests for the KeychainHelper class methods
class KeychainHelperTests: XCTestCase {
    
    let keychainHelper = KeychainHelper()
    
    /// Tests whether credentials can be succesfully created and stored in Keychain
    func testSaveCredentials() {
        
        // Given
        let userID = UUID()
        let isDoctor = true

        // When
        do {
            XCTAssertNoThrow(try keychainHelper.deleteCredentials())
            
            
            XCTAssertNoThrow(try keychainHelper.saveCredentials(userID: userID, isDoctor: isDoctor))
            let storedCredentials = try keychainHelper.retrieveCredentials()

            // Then
            XCTAssertEqual(userID, storedCredentials.userID)
            XCTAssertEqual(isDoctor, storedCredentials.isDoctor)
            XCTAssertFalse(storedCredentials.useBiometrics)
            
        } catch  {
            XCTAssertTrue(false)
        }
    }
    
    
    /// Tests whether existing credentials stored in Keychain can be successfully updated
    func testUpdateCredentials() {

        // Given
        let userID = UUID()
        let formerCredentials = KeychainCredentials(userID: userID, isDoctor: true, useBiometrics: false)
        let latterCredentials = KeychainCredentials(userID: userID, isDoctor: false, useBiometrics: true)
        
        // When
        do {
            XCTAssertNoThrow(try keychainHelper.deleteCredentials())
            
            XCTAssertNoThrow(try keychainHelper.saveCredentials(userID: formerCredentials.userID, isDoctor: formerCredentials.isDoctor))
            let initialRetrievedCredentials = try keychainHelper.retrieveCredentials()
            
            XCTAssertNoThrow(try keychainHelper.updateCredentials(credentials: latterCredentials))
            let updatedRetrievedCredentials = try keychainHelper.retrieveCredentials()
            
            // Then
            XCTAssertEqual(initialRetrievedCredentials.userID, updatedRetrievedCredentials.userID)
            XCTAssertEqual(userID, updatedRetrievedCredentials.userID)
            XCTAssertEqual(updatedRetrievedCredentials.isDoctor, latterCredentials.isDoctor)
            XCTAssertEqual(updatedRetrievedCredentials.useBiometrics, latterCredentials.useBiometrics)
            
        } catch  {
            XCTAssertTrue(false)
        }
    }
    
    /// Tests whether existing credentials can be successfully removed from Keychain
    func testDeleteCredentials() {
        
        // Given
        let givenCredentials = KeychainCredentials(userID: UUID(), isDoctor: true, useBiometrics: false)
        
        // When
        do {
            try keychainHelper.deleteCredentials()
            
            XCTAssertNoThrow(try keychainHelper.saveCredentials(userID: givenCredentials.userID, isDoctor: givenCredentials.isDoctor))
            XCTAssertNoThrow(try keychainHelper.deleteCredentials())
            
            // Then
            XCTAssertThrowsError(try keychainHelper.retrieveCredentials())

        } catch KeychainHelper.KeychainError.noPassword {
            
            XCTAssertTrue(true)
        } catch  {
            XCTAssertTrue(false)
        }
    }
}
