//
//  NotificationScheduleTests.swift
//  NeuroProMedTests
//
//  Created by Marin Novitchi on 22.06.2021.
//

import XCTest

@testable import NeuroProMed

/// Tests for the NotificationSchedule class methods
class NotificationScheduleTests: XCTestCase {
    
    let notificationHelper = NotificationSchedule()
    
    /// Tests whether a notification is successfully created
    func testSetNotification() {
        
        // Given
        let givenAppointment = Appointment(using: Appointment.example)
        
        // When
        notificationHelper.setNotification(for: givenAppointment, message: "Test notification message")
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { notificationRequests in
            let foundNotification = notificationRequests.first(where: { $0.identifier == givenAppointment.appointmentID.uuidString })
            
            // Then
            XCTAssertNotNil(foundNotification)
            
        }
    }
    
    /// Tests whether an existing notification is successfully updated with new title
    func testUpdateNotification() {
        
        // Given
        let givenAppointment = Appointment(using: Appointment.example)
        let formerMessage = "Initial notification message"
        let latterMessage = "Updated notification message"
        
        // When
        notificationHelper.setNotification(for: givenAppointment, message: formerMessage)
        notificationHelper.updateNotification(appointment: givenAppointment, message: latterMessage)
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { notificationRequests in
            let foundNotification = notificationRequests.first(where: { $0.identifier == givenAppointment.appointmentID.uuidString })
            
            // Then
            XCTAssertNotNil(foundNotification)
            XCTAssertEqual(foundNotification?.content.title, latterMessage)
            
        }
    }
    
    /// Tests whether an existing notification is successfully removed
    func testDeleteNotification() {
        
        // Given
        let givenAppointment = Appointment(using: Appointment.example)
        
        // When
        notificationHelper.setNotification(for: givenAppointment, message: "Test notification message")
        notificationHelper.deleteNotification(appointment: givenAppointment)
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { notificationRequests in
            let foundNotification = notificationRequests.first(where: { $0.identifier == givenAppointment.appointmentID.uuidString })
            
            // Then
            XCTAssertNil(foundNotification)
        }
    }

}
