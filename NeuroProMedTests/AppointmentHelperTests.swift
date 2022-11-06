//
//  AppointmentHelperTests.swift
//  NeuroProMedTests
//
//  Created by Marin Novitchi on 22.06.2021.
//

import XCTest

@testable import NeuroProMed

/// Tests for the AppointmentHelper class methods
class AppointmentHelperTests: XCTestCase {
    
    let appointmentHelper = AppointmentHelper()
    let now = Date()
    
    /// Tests whether the computed doctor's availability for the next day takes into account existing appointments
    func testComputeDoctorAvailabilityTomorrow() {
        
        // Given
        let givenDoctor = Doctor(doctorID: UUID(), firstName: "", lastName: "", email: nil, isDoctor: true, isWorkingWeekends: true, specialty: "", unavailability: [Date]())
        let patientID = UUID()
        guard let appointmentDate1 = Calendar.current.date(bySettingHour: 8 , minute: 0, second: 0 , of: now.addingTimeInterval(3600 * 24)), //tomorrow at 8:00
            let appointmentDate2 = Calendar.current.date(bySettingHour: 8 , minute: 20, second: 0 , of: now.addingTimeInterval(3600 * 24)), //tomorrow at 8:20
            let appointmentDate3 = Calendar.current.date(bySettingHour: 8 , minute: 40, second: 0 , of: now.addingTimeInterval(3600 * 24)), //tomorrow at 8:40
            let appointmentDate4 = Calendar.current.date(bySettingHour: 9 , minute: 0, second: 0 , of: now.addingTimeInterval(3600 * 24)) //tomorrow at 9:00
        else {
            XCTAssertTrue(false)
            return
        }
        
        let givenAppointmentsArray = [
            Appointment(appointmentDate: appointmentDate1, doctorID: givenDoctor.doctorID, patientID: patientID, services: [UUID]()),
            Appointment(appointmentDate: appointmentDate2, doctorID: givenDoctor.doctorID, patientID: patientID, services: [UUID]()),
            Appointment(appointmentDate: appointmentDate3, doctorID: givenDoctor.doctorID, patientID: patientID, services: [UUID]()),
            Appointment(appointmentDate: appointmentDate4, doctorID: UUID(), patientID: patientID, services: [UUID]()), // for another doctor
        ]
        
        // When
        let computedDoctorAvailability = appointmentHelper.computeDoctorAvailability(for: givenDoctor, from: givenAppointmentsArray)
        // Then
        XCTAssertEqual(computedDoctorAvailability[now.addingTimeInterval(3600 * 24).setToMidDayGMT()]?.sorted(by: <).first, "09:00")
    }
    
    /// Tests whether the computed doctor's availability takes into account their availability during weekends
    func testComputeDoctorAvailabilityDuringWeekend() {
        
        // Given
        let tomorrow = now.addingTimeInterval(3600 * 24)
        var weekendDay = Calendar.current.date(bySettingHour: 8 , minute: 0, second: 0 , of: tomorrow)
        while weekendDay == nil || !Calendar.current.isDateInWeekend(weekendDay!) {
            weekendDay = Calendar.current.date(byAdding: .day, value: 1, to: weekendDay ?? tomorrow)
        }
        let doctorWorksWeekend = Doctor(doctorID: UUID(), firstName: "", lastName: "", email: nil, isDoctor: true, isWorkingWeekends: true, specialty: "", unavailability: [Date]())
        let doctorDoesntWorkWeekend = Doctor(doctorID: UUID(), firstName: "", lastName: "", email: nil, isDoctor: true, isWorkingWeekends: false, specialty: "", unavailability: [Date]())
        
        // When
        let doctorWorksWeekendAvailability = appointmentHelper.computeDoctorAvailability(for: doctorWorksWeekend, from: [])
        let doctorDoesntWorkWeekendAvailability = appointmentHelper.computeDoctorAvailability(for: doctorDoesntWorkWeekend, from: [])
        // Then
        XCTAssertFalse(doctorWorksWeekendAvailability[weekendDay!.setToMidDayGMT()]!.isEmpty, "Check if the doctor that works on weekend has at least one available slot")
        XCTAssertTrue(doctorDoesntWorkWeekendAvailability[weekendDay!.setToMidDayGMT()] == nil, "Check if the doctor that doesn't work on weekend has no available slot")
    }
    
    /// Tests whether the computed doctor's availability takes into account their days off
    func testComputeDoctorAvailabilityUnavailableNextDay() {
        
        // Given
        let tomorrow = now.addingTimeInterval(3600 * 24).setToMidDayGMT()
        let doctorUnavailableTomorrow = Doctor(doctorID: UUID(), firstName: "", lastName: "", email: nil, isDoctor: true, isWorkingWeekends: true, specialty: "", unavailability: [tomorrow])
        // When
        let computedDoctorAvailability = appointmentHelper.computeDoctorAvailability(for: doctorUnavailableTomorrow, from: [])
        //Then
        XCTAssertTrue(computedDoctorAvailability[tomorrow] == nil, "Check if the doctor that's unavailable tomorrow has no available slots for that day")
    }
    
    /// Tests whether the correct timeslot is computed
    func testGetTimeSlot08h00() {
        
        // Given
        if let givenDate1 = Calendar.current.date(bySettingHour: 8 , minute: 0, second: 0 , of: now) {
            // When
            let formattedTime = appointmentHelper.getTimeSlot(from: givenDate1)
            // Then
            XCTAssertEqual(formattedTime, "08:00")
        }
    }
    
    /// Tests whether the correct timeslot is computed
    func testGetTimeSlot08h05() {
        
        // Given
        if let givenDate2 = Calendar.current.date(bySettingHour: 8 , minute: 5, second: 0 , of: now) {
            // When
            let formattedTime = appointmentHelper.getTimeSlot(from: givenDate2)
            // Then
            XCTAssertEqual(formattedTime, "08:20")
        }
    }
    
    /// Tests whether the correct timeslot is computed
    func testGetTimeSlot08h25() {
        
        // Given
        if let givenDate3 = Calendar.current.date(bySettingHour: 8 , minute: 25, second: 0 , of: now) {
            // When
            let formattedTime = appointmentHelper.getTimeSlot(from: givenDate3)
            // Then
            XCTAssertEqual(formattedTime, "08:40")
        }
    }
    
    /// Tests whether the correct timeslot is computed
    func testGetTimeSlot08h45() {
        
        // Given
        if let givenDate3 = Calendar.current.date(bySettingHour: 8 , minute: 45, second: 0 , of: now) {
            // When
            let formattedTime = appointmentHelper.getTimeSlot(from: givenDate3)
            // Then
            XCTAssertEqual(formattedTime, "09:00")
        }
    }

    
    /// Tests whether the closest upcoming date is correctly identified
    func testGetClosestUpcomingDate() {
        
        // Given
        let givenDatesArray = [
            now.addingTimeInterval(3600 * 24),
            now.addingTimeInterval(3600 * 24 * 2),
            now.addingTimeInterval(3600 * 24 * 3),
            now.addingTimeInterval(3600 * 24 * 4)
        ]
        
        // When
        let closestDate = appointmentHelper.getNearestUpcomingDate(from: givenDatesArray)
        // Then
        XCTAssertEqual(closestDate, now.addingTimeInterval(3600 * 24))
    }
}
