//
//  TodoItem.swift
//  DoItOrElse2
//
//  Created by jose on 2/26/24.
//
enum TodoItemType {
    case ToDo
    case Habit
}

enum TodoItemState {
    case Overdue
    case Normal
    case DueSoon
}
import SwiftUI
import SwiftData
public struct NewTodoView: View {
    @State private var todoType = 0
    @State private var todoName = ""
    @State private var todoCategory = "No Category"
    @State private var todoCategoryColorSelection = Color(.black)
    @State private var todoNewCategoryPresented = false
    @State private var todoNewCategory = ""
    @State private var todoDueDate = Date()
    @FocusState private var focused: Bool
    @Query() var allCategories: [Category]
    public var store: EKEventStore;
    
    private func add() {
        EventsService.shared.addReminder(todoName: todoName, todoDueDate: todoDueDate)
    }
    private func newCategory() {
        Task {
            await EventsService.shared.createNewCategory(name: todoName)
        }
    }
    
    
    let categories = ["No Category", "New Category"]
    let repeatTimes = ["Daily", "Weekly", "Monthly"]
    public var body: some View {
        VStack {
            Text("New To-Do Item").font(.title)
            HStack {
                Picker("Category", selection: $todoCategory) {
                    ForEach(categories, id: \.self) { string in
                        Text(string)
                    }
                    ForEach(allCategories, id: \.self) {category in
                        Text(category.name!)}
                }.onChange(of: todoCategory, {
                    if (todoCategory == "New Category") {
                        todoNewCategoryPresented = true
                    }
                })
                .alert("Create a new category", isPresented: $todoNewCategoryPresented) {
                    TextField("ASSA", text: $todoNewCategory)
                    //                    ColorPicker("Category Color", selection: $todoCategoryColorSelection, supportsOpacity: false)
                    Button(action: newCategory) {
                        Text("OK")
                    }
                }
                Picker("Repeat", selection: $todoCategory) {
                    Text("Repeat")
                    ForEach(repeatTimes, id: \.self) { string in
                        Text(string)
                    }
                }
            }
            DatePicker("Due Date", selection: $todoDueDate, displayedComponents: [.date])
            
            Picker("What's this type of thing?", selection: $todoType) {
                Text("To-Do").tag(0)
                Text("Habit").tag(1)
            }.pickerStyle(.segmented)
            HStack {
                TextField("To-Do", text: $todoName)
                    .padding(8)
                    .overlay(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/).stroke(Color.orange))
                    .focused($focused)
                Button(action: add) {
                    Text("Add")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(15)
        .onAppear{
            focused = true
        }
        .modelContainer(for: Category.self)
    }
}

import Foundation
import EventKit
