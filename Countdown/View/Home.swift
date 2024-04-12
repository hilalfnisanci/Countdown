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
    @AppStorage("isFilterSelected") private var isFilterSelected = false
    
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
                        if isFilterSelected {
                            ForEach(groupedEvents(), id: \.0) { (color, events) in
                                Section(header: GroupHeaderView(color: color)) {
                                    ForEach(events, id: \.self) { event in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(event.title ?? "Unknown Event")
                                                Text("\(remainingTime(for: event.eventDate ?? Date())) left")
                                                    .foregroundColor(.gray)
                                            }
                                            .swipeActions(edge: .trailing) {
                                                Button {
                                                    deleteEvent(event)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                                .tint(.red)
                                                
                                                Button {
                                                    editEvent(event)
                                                } label: {
                                                    Label("Edit", systemImage: "pencil.circle")
                                                }
                                                .tint(.indigo)
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
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
                                    .swipeActions(edge: .trailing) {
                                        Button {
                                            deleteEvent(event)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        .tint(.red)
                                        
                                        Button {
                                            editEvent(event)
                                        } label: {
                                            Label("Edit", systemImage: "pencil.circle")
                                        }
                                        .tint(.indigo)
                                    }
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
            .navigationBarItems(trailing: HStack {
                Button(action: {
                    isFilterSelected.toggle()
                    if isFilterSelected {

                    }else {

                    }
                    
                }) {
                    Image(systemName: isFilterSelected ? "paintpalette.fill" : "paintpalette")
                        .foregroundColor(.primary)
                }
                Button(action: {
                    isDarkMode.toggle()
                    if isDarkMode {
                        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
                    } else {
                        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
                    }
                }) {
                    Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                        .foregroundColor(.primary)
                }
            })
            .sheet(isPresented: $isAddEventPresented) {
                AddNewEvent(countdownModel: countdownModel, eventToEdit: eventToEdit)
            }
            .onAppear {
                countdownModel.scheduleNotifications(for: events)
            }
        }
    }
    
    func groupedEvents() -> [(String, [Countdown])] {
        var groupedEvents = Dictionary(grouping: events) { $0.eventColor ?? "Card-1" }
        let sortedEvents: [(String, [Countdown])] = isFilterSelected ? groupedEvents.sorted(by: { $0.key < $1.key }) : groupedEvents.sorted(by: { $0.value.first!.eventDate! < $1.value.first!.eventDate! })
        return sortedEvents
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

struct GroupHeaderView: View {
    var color: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(color))
                .frame(width: 20, height: 20)
        }
    }
}

#Preview {
    ContentView()
}
