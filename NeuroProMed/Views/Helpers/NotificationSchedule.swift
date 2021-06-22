//
//  NotificationSchedule.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 27.04.2021.
//

import Foundation
import SwiftUI

/// Schedule notifications
struct NotificationSchedule: Codable, Hashable {
    
    let description: String
    let calendarComponent: Calendar.Component
    let value: Int
    
    init() {
        description = ""
        calendarComponent = .calendar
        value = -1
    }
    
    init(description: String, calendarComponent: Calendar.Component, value: Int) {
        self.description = description
        self.calendarComponent = calendarComponent
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        description = try container.decode(String.self, forKey: .description)
        let stringComponent = try container.decode(String.self, forKey: .calendarComponent)
        switch stringComponent {
        case "second":
            calendarComponent = .second
        case "minute":
            calendarComponent = .minute
        case "hour":
            calendarComponent =  .hour
        case "day":
            calendarComponent =  .day
        case "weekOfMonth":
            calendarComponent =  .weekOfMonth
        case "weekOfYear":
            calendarComponent =  .weekOfYear
        case "month":
            calendarComponent =  .month
        default:
            calendarComponent =  .calendar
        }
        value = try container.decode(Int.self, forKey: .value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(description, forKey: .description)
        try container.encode("\(calendarComponent)", forKey: .calendarComponent)
        try container.encode(value, forKey: .value)
    }
    
    enum CodingKeys: CodingKey {
        case description, calendarComponent, value
    }
    
    
    /// Set local notification
    /// - Parameters:
    ///   - appointment: Appointment for which the notification is to be scheduled
    ///   - message: Message to be displayed in the notification
    func setNotification(for appointment: Appointment, message: String) {
        
        guard let unwrappedNotificationDate = Calendar.current.date(byAdding: calendarComponent, value: -value, to: appointment.appointmentDate) else { return  }
        guard value > -1 else { return }
        
        let dateComponentsFormatter = DateComponentsFormatter()
        let title = String(format: NSLocalizedString("upcomingAppointmentInX", comment: "Upcoming notification message"), dateComponentsFormatter.string(from: unwrappedNotificationDate, to: appointment.appointmentDate) ?? "near future")
        
        createNotification(identifier: appointment.appointmentID, title: title, body: message, scheduledFor: unwrappedNotificationDate)
    }
    
    /// Update existing local notification
    /// - Parameters:
    ///   - appointment: Appointment for which the notification is to be updated
    ///   - message: Message to be displayed in the notification
    func updateNotification(appointment: Appointment, message: String) {
        deleteNotification(appointment: appointment)
        setNotification(for: appointment, message: message)
    }
    
    /// Delete existing local notification
    /// - Parameter appointment: Appointment fo which the notification is to be deleted
    func deleteNotification(appointment: Appointment) {
        
        getNotifications() { notificationRequests in
            guard let foundNotification = notificationRequests.first(where: { $0.identifier == appointment.appointmentID.uuidString }) else { return }
            
            deleteNotificationSchedule(identifiedBy: appointment.appointmentID)
            deleteNotifications(withIdentifiers: [foundNotification.identifier])
        }
    }
    
    /// Request permission to schedule local notifications
    /// - Parameters:
    ///   - center: Optional UNUserNotificationCenter object to use for scheduling notifications
    ///   - completion: Action to be performed once the response is received
    func requestAuthorization(center: UNUserNotificationCenter?, completion: @escaping (Bool) -> Void) {
        if let unwrappedCenter = center {
            requestAuthorization(center: unwrappedCenter, completion: completion)
        } else {
            let center = UNUserNotificationCenter.current()
            requestAuthorization(center: center, completion: completion)
        }
    }
    
    
    
    /// Request permission to schedule local notifications
    /// - Parameters:
    ///   - center: UNUserNotificationCenter object to use for scheduling notifications
    ///   - completion: Action to be performed once the response is received
    private func requestAuthorization(center: UNUserNotificationCenter, completion: @escaping (Bool) -> Void) {
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                completion(true)
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    completion(success)
                }
            }
        }
    }
    
    /// Creates saves a notification object
    /// - Parameters:
    ///   - identifier: Notification identifier
    ///   - title: Notification title
    ///   - body: Notification content
    ///   - notificationDate: The date when the notification is to be triggered
    private func createNotification(identifier: UUID, title: String, body: String, scheduledFor notificationDate: Date) {
        let center = UNUserNotificationCenter.current()
        let addRequest = {
            let content = UNMutableNotificationContent()
            let dateComponentsFormatter = DateComponentsFormatter()
            dateComponentsFormatter.unitsStyle = .brief
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Date().distance(to: notificationDate), repeats: false)
            //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(15), repeats: false)
            let request = UNNotificationRequest(identifier: identifier.uuidString, content: content, trigger: trigger)
            center.add(request)
        }

        requestAuthorization(center: center, completion: { isAllowed in
            if isAllowed {
                addRequest()
                saveNotificationSchedule(identifiedBy: identifier)
            }
        })
    }
    
    /// Get the current pending notifications
    /// - Parameter completion: Action to be performed once the response is received
    private func getNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notificationRequests in
            completion(notificationRequests)
        }
    }
    
    /// Delete all pending notifications that match the provided identifiers
    /// - Parameter identifiers: Identifiers for the notifications to be deleted
    private func deleteNotifications(withIdentifiers identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    /// Save the notification schedule object in the UserDefaults
    /// - Parameter identifier: Notification identifier
    private func saveNotificationSchedule(identifiedBy identifier: UUID) {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: identifier.uuidString)
        }
    }
    
    /// Delete the notification schedule object from the UserDefaults
    /// - Parameter identifier: Notification identifier
    private func deleteNotificationSchedule(identifiedBy identifier: UUID) {
        UserDefaults.standard.removeObject(forKey: identifier.uuidString)
    }
}

