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
    @Environment(\.presentationMode) var presentationMode
    var dismissDelegate: DismissDelegate?
    
    init(reminderId: String? = nil, reminder: EKReminder? = nil) {
        self.reminderId = reminderId
        self.reminder = EventsService.shared.getReminderById(reminderId!);
    }
    public var body: some View {
        VStack {
            Text(reminder!.title!)
            Text(reminder!.startDateComponents?.description ?? "")
            HStack {
                Button(action: {
                    EventsService.shared.markComplete(reminder!)
                    presentationMode.wrappedValue.dismiss()
                    dismissDelegate?.didDismissSwiftUIView()

                }) {
                    Text("Mark Complete")
                }
                Button(action: {
                    
                    EventsService.shared.removeReminder(reminder!)
                    presentationMode.wrappedValue.dismiss()
                    dismissDelegate?.didDismissSwiftUIView()
                }) {
                    Text("Delete Reminder").foregroundStyle(.red)
                }
                //            .background(Color.red)
                .buttonStyle(.bordered)
            }
        }
    }
}
