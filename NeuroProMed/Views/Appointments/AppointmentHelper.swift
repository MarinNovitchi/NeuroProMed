//
//  AppointmentHelper.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 20.04.2021.
//

import Foundation


/// Manages appointment scheduling logic
class AppointmentHelper {
    
    /// Get the time of the nearest appointment slot
    /// - Parameter appointmentDate: Desired date of the appointment
    /// - Returns: The timeslot of the next appointment in string forrmat
    func getTimeSlot(from appointmentDate: Date) -> String {
        let cal = Calendar.current.dateComponents([.hour, .minute], from: appointmentDate)
        if var hours = cal.hour, let minutes = cal.minute {
            let minutesPart: String
            switch minutes {
            case 0:
                minutesPart = "00"
            case 1...20:
                minutesPart = "20"
            case 21...40:
                minutesPart = "40"
            case 41...59:
                minutesPart = "00"
                hours += 1
            default:
                minutesPart = "40"
            }
            let hoursPart = hours > 9 ? String(hours) : "0\(hours)"
            return hoursPart + ":" + minutesPart
        }
        return ""
    }
    
    /// Get the nearest upcoming date
    /// - Parameter dates: Dates array from which to choose the nearest date
    /// - Returns: Nearest upcoming date
    func getNearestUpcomingDate(from dates: [Date]) -> Date {
        dates.reduce(dates[0]) { $0.compare($1) == .orderedAscending ? $0 : $1 }
    }
    
    
    /// Gets a dictionary of dates and available slots for appointments for a particular doctor
    /// - Parameters:
    ///   - doctor: The doctor for which the availability is computed
    ///   - appointments: All existing appointments
    /// - Returns: A dictionary of dates and available slots for appointments
    func computeDoctorAvailability(for doctor: Doctor, from appointments: [Appointment]) -> [Date: [String]] {

        let doctorUpcomingAppointments = appointments.filter{
            $0.doctorID == doctor.doctorID &&
            $0.appointmentDate.compare(today) == .orderedDescending
        }
        if doctorUpcomingAppointments.count > 0 {
            let doctorAppointmentsByDate = Dictionary(grouping: doctorUpcomingAppointments, by: { $0.appointmentDate.setToMidDayGMT() })
            let doctorOccupiedAgenda = getBookedTimeSlots(from: doctorAppointmentsByDate)
            return createTimeSlots(for: doctor, considering: doctorOccupiedAgenda)
        } else {
            return createTimeSlots(for: doctor, considering: nil)
        }
    }
    
    private let allTimeSlots = ["08:00", "08:20", "08:40", "09:00", "09:20", "09:40", "10:00", "10:20", "10:40", "11:00", "11:20", "11:40", "12:00", "12:20", "12:40", "13:00", "13:20", "13:40"]
    
    private let today = Date()
    
    
    /// Creates the available timeslots for a particular doctor taking into account his/her existing appointments
    /// - Parameters:
    ///   - doctor: The doctor for which the available timeslots should be created
    ///   - doctorAgenda: Doctor's current agenda of existing appointments
    /// - Returns: A dictionary of dates and available slots for appointments
    private func createTimeSlots(for doctor: Doctor, considering doctorAgenda:[Date: [String]]?) -> [Date: [String]] {
        
        var doctorAvailability = [Date: [String]]()
        let minDays = 15
        let minTimeSlots = minDays * allTimeSlots.count
        var targetDays = 0
        var targetTimeSlots = 0
        var dayIncrement = 1
        
        let todayAtMidDay = today.setToMidDayGMT()
        if !isUnavailable(doctor, on: todayAtMidDay) {
 
            doctorAvailability[todayAtMidDay] = getRemainingSlotsForToday().difference(from: doctorAgenda?[todayAtMidDay] ?? [String]())
            
            if doctorAvailability[todayAtMidDay]?.count == 0 {
                doctorAvailability.removeValue(forKey: todayAtMidDay)
            } else {
                targetDays = 1
                targetTimeSlots = doctorAvailability[todayAtMidDay]?.count ?? 0
            }
        }

        while targetDays < minDays && targetTimeSlots < minTimeSlots {
            guard let newDay = Calendar.current.date(byAdding: .day, value: dayIncrement, to: todayAtMidDay) else {
                dayIncrement += 1
                continue
            }
            if isUnavailable(doctor, on: newDay) {
                dayIncrement += 1
                continue
            }
            doctorAvailability[newDay] = allTimeSlots.difference(from: doctorAgenda?[newDay] ?? [String]())
            dayIncrement += 1
            targetDays += 1
            targetTimeSlots += doctorAvailability[newDay]!.count
        }
        return doctorAvailability
    }
    
    
    /// Get the remaining available time slots for the current day
    /// - Returns: An array of the remaining available time slots for the current day
    private func getRemainingSlotsForToday() -> [String] {
        let now = Date()
        if isPriorToOpeningHours(now) {
            return allTimeSlots
        }
        var remainingSlots = allTimeSlots
        let slotForCurrentHour = getTimeSlot(from: now) // 07:51 -> 08:00
        let trimUpperBound: Int = remainingSlots.firstIndex(of: slotForCurrentHour) ?? remainingSlots.count
        if trimUpperBound > 0 {
            remainingSlots.removeSubrange(0...trimUpperBound - 1)
        }
        return remainingSlots
    }
    
    
    /// Check if the hour of a given date is prior to the business opening hour
    /// - Parameter givenDate:A particular date for which the check must be performed
    /// - Returns: A boolean value indicating whether the given fate is or isn't prior to the business opening hour
    private func isPriorToOpeningHours(_ givenDate: Date) -> Bool {
        if let currentHour = Calendar.current.dateComponents([.hour], from: givenDate).hour {
            return currentHour < 8
        }
        return false
    }
    
    
    /// Check if the doctor is unavailable for appointments on a particular date
    /// - Parameters:
    ///   - doctor: The doctor for which the check must be performed
    ///   - day: The day for which the doctor availablity must be verified
    /// - Returns: A boolean value indicating whether the doctor is or isn't available
    private func isUnavailable(_ doctor: Doctor, on day: Date) -> Bool {
        doctor.unavailability.contains(day.setToMidDayGMT()) || (!doctor.isWorkingWeekends && Calendar.current.isDateInWeekend(day))
    }
    
    
    /// Get the already booked timeslots
    /// - Parameter appointmentsByDate: A dictionary of dates and the existing appointments of those dates
    /// - Returns: A dictionary of dates and the timeslots of the existing appointments of those dates
    private func getBookedTimeSlots(from appointmentsByDate: [Date: [Appointment]]) -> [Date: [String]] {
        var agenda: [Date: [String]] = [Date: [String]]()
        for dayOfAppointments in appointmentsByDate {
            agenda[dayOfAppointments.key] = dayOfAppointments.value.map{ appointment in
                getTimeSlot(from: appointment.appointmentDate)
            }
        }
        return agenda
    }
}
