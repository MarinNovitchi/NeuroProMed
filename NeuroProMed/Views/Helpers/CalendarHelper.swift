//
//  CalendarHelper.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 10.05.2021.
//

import EventKit
import Foundation

/// Manage calendar events that correspond to appointments
class CalendarHelper {
    
    private static let eventStore = EKEventStore()
    
    /// Checks whether the permission to access the user's calendars is granted and requests it if it isn't
    /// - Returns: A boolean value indicating whether the permission to access calendars is granted
    func checkAndAskForPermission() -> Bool {
        var response = false
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            response = true
        case .denied:
            response = false
        case .notDetermined:
            Self.eventStore.requestAccess(to: .event) { isGranted, error in
                if error != nil {
                    response = false
                }
                response = isGranted
            }
            default:
                print("Case default")
        }
        return response
    }
    
    /// Get user's current calendars
    /// - Returns: String array containing user's calendar names
    func getCalendars() -> [String] {
        
        let calendars = Self.eventStore.calendars(for: .event)
        return [NSLocalizedString("notificationNone", comment: "Notification Schedule - None")] + calendars.map{ $0.title }
    }
    
    /// Get the calendar for a particular date
    /// - Parameter eventDate: date of the event when the appointment is held
    /// - Returns: The name of the calendar where the event is present
    func getCalendar(for eventDate: Date) -> String? {
        
        guard checkAndAskForPermission() else {
            return nil
        }
        
        let predicate = Self.eventStore.predicateForEvents(withStart: eventDate, end: eventDate.addingTimeInterval(20*60), calendars: nil)
        let events = Self.eventStore.events(matching: predicate)
        if let event = events.first(where: { $0.location == "NeuroProMed" }) {
            return event.calendar.title
        }
        return nil
    }
    
    /// Creates an event in a particular calendar that corresponds to the scheduled appointment
    /// - Parameters:
    ///   - appointment: Appointment for which the event should be created
    ///   - selectedCalendar: Calendar name where the event should be created
    ///   - title: Title of the event
    func add(appointment: Appointment, to selectedCalendar: String, title: String) {
        
        guard checkAndAskForPermission() else {
            return
        }
        
        let calendars = Self.eventStore.calendars(for: .event)
        guard let calendar = calendars.first(where: { $0.title == selectedCalendar }) else { return }
        
        let startDate = appointment.appointmentDate
        let endDate = startDate.addingTimeInterval(20 * 60)

        let event = EKEvent(eventStore: Self.eventStore)
        
        event.calendar = calendar
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.location = "NeuroProMed"
            
        do {
            try Self.eventStore.save(event, span: .thisEvent)
        }
        catch {
           print("Error saving event in calendar")
            
        }
    }
    
    /// Updates the event that corresponds to the scheduled appointment
    /// - Parameters:
    ///   - selectedCalendar: Calendar name where the event should be created
    ///   - originalDate: Date when the appointment was previously held
    ///   - newAppointment: Appointment with updated date
    ///   - title: Title of the event
    func update(selectedCalendar: String, on originalDate: Date, with newAppointment: Appointment, title: String) {
        guard checkAndAskForPermission() else {
            return
        }
        let calendars = Self.eventStore.calendars(for: .event)
        guard let calendar = calendars.first(where: { $0.title == selectedCalendar }) else {
            if selectedCalendar == NSLocalizedString("notificationNone", comment: "Notification Schedule - None") {
                deleteEvent(on: originalDate)
            }
            return
        }

        let predicate = Self.eventStore.predicateForEvents(withStart: originalDate, end: originalDate.addingTimeInterval(20*60), calendars: nil)
        let events = Self.eventStore.events(matching: predicate)
        
        if let event = events.first(where: { $0.location == "NeuroProMed" }) {
            event.startDate = newAppointment.appointmentDate
            event.endDate = newAppointment.appointmentDate.addingTimeInterval(20*60)
            event.title = title
            event.calendar = calendar
            
            do {
                try Self.eventStore.save(event, span: .thisEvent)
            }
            catch {
               print("Error saving event in calendar")
            }
        } else {
            add(appointment: newAppointment, to: selectedCalendar, title: title)
        }
    }
    
    /// Delete the event that corresponds to the scheduled appointment
    /// - Parameter appointmentDate: date when the appointment is held
    func deleteEvent(on appointmentDate: Date) {
        guard checkAndAskForPermission() else {
            return
        }

        let predicate = Self.eventStore.predicateForEvents(withStart: appointmentDate, end: appointmentDate.addingTimeInterval(20*60), calendars: nil)
        let events = Self.eventStore.events(matching: predicate)
        
        if let event = events.first(where: { $0.location == "NeuroProMed" }) {
            
            do {
                try Self.eventStore.remove(event, span: .thisEvent)
            }
            catch {
               print("Error saving event in calendar")
            }
        }
    }
}
