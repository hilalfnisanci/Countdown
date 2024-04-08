//
//  AddNewEvent.swift
//  Countdown
//
//  Created by Hilal on 2.04.2024.
//

import SwiftUI

struct AddNewEvent: View {
    @ObservedObject var countdownModel: CountdownViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.self) var env
    
    var eventToEdit: Countdown?
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 50)
            
            TextField("Event Title", text: $countdownModel.title)
                .padding()
            DatePicker("Event Date", selection: $countdownModel.eventDate, displayedComponents: .date)
                .padding()
            
            Divider()
            
            HStack(spacing: 0) {
                ForEach(1...7, id: \.self){ index in
                    let color = "Card-\(index)"
                    Circle()
                        .fill(Color(color))
                        .frame(width: 40, height: 40)
                        .overlay(content: {
                            if color == countdownModel.eventColor {
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                            }
                        })
                        .onTapGesture {
                            withAnimation {
                                countdownModel.eventColor = color
                            }
                        }
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical)
            
            Spacer()
            
            HStack {
                Spacer()
                Button(action: {
                    if let event = eventToEdit {
                        countdownModel.saveEvent(editingEvent: event)
                    } else {
                        countdownModel.addEvent()
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "checkmark")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                }
                .frame(width: 35, height: 35)
                .background(Circle().foregroundColor(Color.orange))
                .clipShape(Circle())
            }
            
            .padding()
        }
        .navigationTitle("Add New Event")
        .onAppear {
            if eventToEdit == nil {
                countdownModel.resetEvent()
            } else {
                countdownModel.title = eventToEdit?.title ?? ""
                countdownModel.eventDate = eventToEdit?.eventDate ?? Date()
                countdownModel.eventColor = eventToEdit?.eventColor ?? "Card-1"
            }
        }
    }
}

#Preview {
    AddNewEvent(countdownModel: CountdownViewModel())
}
