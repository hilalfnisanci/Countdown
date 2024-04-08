//
//  Home.swift
//  Countdown
//
//  Created by Hilal on 30.03.2024.
//

import SwiftUI

struct Home: View {
    @FetchRequest(entity: Countdown.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Countdown.eventDate, ascending: true)], predicate: nil, animation: .easeInOut) var events: FetchedResults<Countdown>
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @StateObject var countdownModel: CountdownViewModel = .init()
    @State private var isAddEventPresented = false
    
    @State var eventToEdit: Countdown?
    
    var body: some View {
        NavigationView {
            VStack {
                if events.isEmpty {
                    Spacer()
                    
                    Image(.surprise)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350)
                        .padding(.bottom, 10)
                    
                    Text("No events here yet")
                        .font(.headline)
                        .padding(.top, 5)
                    
                    Spacer()
                } else {
                    List {
                        ForEach(events, id: \.self) { event in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(Color(event.eventColor ?? "Card-1"))
                                    .frame(width: 20, height: 20)
                                
                                VStack(alignment: .leading) {
                                    Text(event.title ?? "Unknown Event")
                                    Text("\(remainingTime(for: event.eventDate ?? Date())) left")
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                
                                HStack {
                                    Button(action: {
                                        editEvent(event)
                                    }) {
                                        Image(systemName: "pencil.circle")
                                            .foregroundColor(.green)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Button(action: {
                                        deleteEvent(event)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            
                        }
                    }
                }
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        self.eventToEdit = nil
                        countdownModel.resetEvent()
                        isAddEventPresented = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                            .padding()
                    }
                }
            }
            .navigationBarItems(trailing: Button(action: {
                isDarkMode.toggle()
                if isDarkMode {
                    UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
                } else {
                    UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
                }
            }) {
                Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                    .foregroundColor(.primary)
            })
            .sheet(isPresented: $isAddEventPresented) {
                AddNewEvent(countdownModel: countdownModel, eventToEdit: eventToEdit)
            }
            .onAppear {
                countdownModel.scheduleNotifications(for: events)
            }
        }
    }
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    func remainingTime(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        let components = calendar.dateComponents([.day, .hour, .minute], from: now, to: date)
        
        if let day = components.day{
            return String(format: "%02d days", day)
        }
        
        return ""
    }
    
    func deleteEvent(_ event: Countdown) {
        PersistenceController.shared.container.viewContext.delete(event)
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            print("Error deleting event: \(error)")
        }
    }
    
    func editEvent(_ event: Countdown) {
        self.eventToEdit = event
        self.prepareCountdownModel()
        self.isAddEventPresented = true
    }
    
    func prepareCountdownModel() {
        if let eventToEdit = eventToEdit {
            countdownModel.title = eventToEdit.title ?? ""
            countdownModel.eventDate = eventToEdit.eventDate ?? Date()
            countdownModel.eventColor = eventToEdit.eventColor ?? "Card-1"
        }
    }
}


#Preview {
    ContentView()
}
