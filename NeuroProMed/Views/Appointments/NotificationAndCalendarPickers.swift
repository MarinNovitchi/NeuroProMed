//
//  NotificationAndCalendarPickers.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 29.05.2021.
//

import SwiftUI

struct NotificationAndCalendarPickers: View {
    
    @Binding var notificationSchedule: NotificationSchedule
    @Binding var selectedCalendar: String
    
    @State private var isNotificationEnabled = false
    @State private var isCalendarEnabled = false
    
    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    
    let notificationIntervals = [
        NotificationSchedule(description: NSLocalizedString("notificationNone", comment: "Notification Schedule - None"), calendarComponent: .calendar, value: -1),
        NotificationSchedule(description: NSLocalizedString("notification10min", comment: "Notification Schedule - 10 minutes before"), calendarComponent: .minute, value: 10),
        NotificationSchedule(description: NSLocalizedString("notification15min", comment: "Notification Schedule - 15 minutes before"), calendarComponent: .minute, value: 15),
        NotificationSchedule(description: NSLocalizedString("notification20min", comment: "Notification Schedule - 20 minutes before"), calendarComponent: .minute, value: 20),
        NotificationSchedule(description: NSLocalizedString("notification30min", comment: "Notification Schedule - 30 minutes before"), calendarComponent: .minute, value: 30),
        NotificationSchedule(description: NSLocalizedString("notification1h", comment: "Notification Schedule - 1 hour before"), calendarComponent: .hour, value: 1),
        NotificationSchedule(description: NSLocalizedString("notification2h", comment: "Notification Schedule - 2 hours before"), calendarComponent: .hour, value: 2),
        NotificationSchedule(description: NSLocalizedString("notification1d", comment: "Notification Schedule - 1 day before"), calendarComponent: .day, value: 1),
        NotificationSchedule(description: NSLocalizedString("notification2d", comment: "Notification Schedule - 2 days before"), calendarComponent: .day, value: 2),
        NotificationSchedule(description: NSLocalizedString("notification1w", comment: "Notification Schedule - 1 week before"), calendarComponent: .weekOfYear, value: 1)]
    
    func checkAndAskForPermission() {
        askForNotificationPermission() { isEnabled in
            isNotificationEnabled = isEnabled
            isCalendarEnabled = askForCalendarPermission()
        }
    }
    
    func askForNotificationPermission(completion: @escaping (Bool) -> Void) {
        notificationSchedule.requestAuthorization(center: nil, completion: completion)
    }
    
    func askForCalendarPermission() -> Bool {
        let calendar = CalendarHelper()
        return calendar.checkAndAskForPermission()
    }
    
    func notificationPickerSet(newValue: NotificationSchedule) {
        if isNotificationEnabled {
            notificationSchedule = newValue
        } else {
            askForNotificationPermission() { isAllowed in
                if isAllowed {
                    notificationSchedule = newValue
                } else {
                    isShowingAlert = true
                }
            }
        }
    }
    
    func calendarPickerSet(newValue: String) {
        if isCalendarEnabled {
            selectedCalendar = newValue
        } else {
            if askForCalendarPermission() {
                selectedCalendar = newValue
            } else {
                isShowingAlert = true
            }
        }
    }
    
    var body: some View {
        CustomSection(header: Text(label(.notificationAndCalendar)))  {
            
            Picker(label(.notificationAlert), selection: Binding<NotificationSchedule>(
                    get: { notificationSchedule },
                    set: notificationPickerSet
            )) {
                ForEach(notificationIntervals, id: \.self) { interval in
                    Text(interval.description)
                }
            }
            
            Picker(label(.addToCalendar), selection: Binding<String>(
                    get: { selectedCalendar },
                    set: calendarPickerSet
            )) {
                ForEach(CalendarHelper().getCalendars(), id: \.self) {
                    Text($0)
                }
            }
        }
        .onAppear(perform: checkAndAskForPermission)
        .alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text(label(.notificationAndCalendarPermissionDenied)),
                message: Text(alertMessage),
                primaryButton: .cancel(),
                secondaryButton: .default(Text(label(.appSettings)), action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                })
            )
        }
    }
}

struct NotificationAndCalendarPickers_Previews: PreviewProvider {
    static var previews: some View {
        NotificationAndCalendarPickers(notificationSchedule: .constant(NotificationSchedule(description: NSLocalizedString("notificationNone", comment: "Notification Schedule - None"), calendarComponent: .calendar, value: -1)), selectedCalendar: .constant(NSLocalizedString("notificationNone", comment: "Notification Schedule - None")))
    }
}
