//
//  ReminderDetailsView.swift
//  DoItOrElse2
//
//  Created by jose on 3/15/24.
//

import Foundation
import SwiftUI
import EventKit

public struct ReminderDetailsView: View {
    public var reminderId: String?;
    public var reminder: EKReminder?;
    @State private var deleteShown: Bool = false;
    @Environment(\.presentationMode) var presentationMode
    var dismissDelegate: DismissDelegate?
    
    init(reminderId: String? = nil, reminder: EKReminder? = nil) {
        self.reminderId = reminderId
        self.reminder = EventsService.shared.getReminderById(reminderId!);
    }
    public var body: some View {
        VStack {
            Text(reminder!.title!).font(.title)
            Text((reminder!.creationDate?.formatted(.dateTime))!).font(.title3)
            HStack {
                Button(action: {
                    EventsService.shared.markComplete(reminder!)
                    presentationMode.wrappedValue.dismiss()
                    dismissDelegate?.didDismissSwiftUIView()

                }) {
                    Text("Mark Complete")
                }
                Button(action: {
                    deleteShown = true
                }) {
                    Text("Delete Reminder").foregroundStyle(.red)
                }
                //            .background(Color.red)
                .buttonStyle(.bordered)
            }
        }
        .alert(
                    "really?",
                    isPresented: $deleteShown,
                    presenting: "don't delete reminders that are legitimate. continue?"
        ) { details in
                    Button(role: .destructive) {
                        // Handle the deletion.
                        EventsService.shared.removeReminder(reminder!)
                        presentationMode.wrappedValue.dismiss()
                        dismissDelegate?.didDismissSwiftUIView()
                    } label: {
                        Text("yup")
                    }
                    Button("nope") {
                        presentationMode.wrappedValue.dismiss()
                        // Handle the retry action.
                    }
                } message: { details in
                }    }
}
