//
//  CalendarHelperTests.swift
//  NeuroProMedTests
//
//  Created by Marin Novitchi on 22.06.2021.
//

import Foundation
import XCTest

@testable import NeuroProMed

/// Tests for the CalendarHelper class methods
class CalendarHelperTests: XCTestCase {
    
    let calendarHelper = CalendarHelper()
    
    /// Tests whether the event associated with an appointment is successfully added to a given calendar
    func testAdd() {
        
        // Given
        let appointmentDate = Date().setToMidDayGMT()
        let givenAppointment = Appointment(appointmentDate: Date().setToMidDayGMT(), doctorID: UUID(), patientID: UUID(), services: [UUID]())
        let selectedCalendar = "Calendar"
        
        // When
        calendarHelper.add(appointment: givenAppointment, to: selectedCalendar, title: "Test Appointment")
        let retrievedCalendar = calendarHelper.getCalendar(for: appointmentDate)
        calendarHelper.deleteEvent(on: appointmentDate)
        
        // Then
        XCTAssertNotNil(retrievedCalendar)
        XCTAssertEqual(selectedCalendar, retrievedCalendar)
        
    }
    
    /// Tests whether an existing event associated with an appointment is successfully updated
    func testUpdate() {
        
        // Given
        let formerAppointmentDate = Date().setToMidDayGMT()
        let latterAppointmentDate = formerAppointmentDate.addingTimeInterval(3600 * 24).setToMidDayGMT()
        
        let givenAppointment = Appointment(appointmentDate: formerAppointmentDate, doctorID: UUID(), patientID: UUID(), services: [UUID]())
        let selectedCalendar = "Calendar"
        
        // When
        calendarHelper.add(appointment: givenAppointment, to: selectedCalendar, title: "Test Appointment")
        givenAppointment.appointmentDate = latterAppointmentDate
        calendarHelper.update(selectedCalendar: selectedCalendar, on: formerAppointmentDate, with: givenAppointment, title: "Updated Test Appointment")
        
        let retrievedCalendar = calendarHelper.getCalendar(for: latterAppointmentDate)
        calendarHelper.deleteEvent(on: latterAppointmentDate)
        
        XCTAssertNotNil(retrievedCalendar)
        if let unwrappedRetrievedCalendar = retrievedCalendar {
            XCTAssertEqual(selectedCalendar, retrievedCalendar)
        }
    }
    
    /// Tests whether an existing event associated with an appointment is successfully removed from the calendar
    func testDelete() {
        
        // Given
        let givenAppointment = Appointment(appointmentDate: Date().setToMidDayGMT(), doctorID: UUID(), patientID: UUID(), services: [UUID]())
        let formerCalendar = "Calendar"
        let latterCalendar = NSLocalizedString("notificationNone", comment: "Notification Schedule - None")
        
        // When
        calendarHelper.add(appointment: givenAppointment, to: formerCalendar, title: "Test Appointment")
        calendarHelper.update(selectedCalendar: latterCalendar, on: givenAppointment.appointmentDate, with: givenAppointment, title: "Event should no longer be present")
        
        // Then
        XCTAssertNil(calendarHelper.getCalendar(for: givenAppointment.appointmentDate))
    }
}
