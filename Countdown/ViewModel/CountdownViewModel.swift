//
//  CountdownViewModel.swift
//  Countdown
//
//  Created by Hilal on 30.03.2024.
//

import SwiftUI
import CoreData
import UserNotifications

class CountdownViewModel: ObservableObject {
    
    @Published var addNewEvent: Bool = false
    @Published var title: String = ""
    @Published var eventDate: Date = Date()
    @Published var notificationAccess: Bool = false
    @Published var eventColor: String = "Card-1"
    
    
    init(){
        requestNotificationAccess()
    }
    
    
    func requestNotificationAccess(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert]) { status, _ in
            DispatchQueue.main.async {
                self.notificationAccess = status
            }
        }
    }
    
    func scheduleNotifications(for events: FetchedResults<Countdown>) {
        let center = UNUserNotificationCenter.current()
        for event in events {
            let content = UNMutableNotificationContent()
            content.title = event.title ?? "Unknown Event"
            content.body = "Event \(event.title ?? "Unknown Event") is approaching!"
            content.sound = UNNotificationSound.default

            var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: event.eventDate ?? Date())
            dateComponents.hour = 0
            dateComponents.minute = 48

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request) { (error) in
                if let error = error {
                    // Handle any errors
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }

    func addEvent() {
        guard !title.isEmpty else {
            return
        }
        
        let newEvent = Countdown(context: PersistenceController.shared.container.viewContext)
        newEvent.title = title
        newEvent.eventDate = eventDate
        newEvent.eventColor = eventColor
        
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            // Handle error
            print("Error saving new event: \(error)")
        }
        
        title = ""
        eventDate = Date()
        eventColor = "Card-1"
    }
    
    func saveEvent(editingEvent: Countdown? = nil) {
        let event = editingEvent ?? Countdown(context: PersistenceController.shared.container.viewContext)
        event.title = title
        event.eventDate = eventDate
        event.eventColor = eventColor
                
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            // Handle error
            print("Error saving event: \(error)")
        }
        
        if editingEvent == nil {
            title = ""
            eventDate = Date()
            eventColor = "Card-1"
        }
    }
    
    func resetEvent() {
        self.title = ""
        self.eventDate = Date()
        self.eventColor = "Card-1"
    }
    
    
}
