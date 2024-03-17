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
enum TodoStaticOptions: String, CaseIterable {
    case None
    case New
}
enum TodoRepeat: String, CaseIterable {
    case Never
    case PerDay
    case PerWeek
}
import SwiftUI
import EventKit
import SwiftData
public struct NewTodoView: View {
    @State private var todoType: TodoItemType = .ToDo;
    @State private var todoRepeat: TodoRepeat = .Never;
    @State private var todoName = ""
    @State private var todoCategoryId: String = "None";
    @State private var todoCategoryColorSelection = Color(.black)
    @State private var todoNewCategoryPresented = false
    @State private var remindMeCategory = false
    @State private var todoNewCategory = ""
    @State private var todoDueDate: Date?;
    @FocusState private var focused: Bool
    @Query() private var allCats: [Category]
    @State var allCategories: [Category]?;
    @Environment(\.presentationMode) var presentationMode
    
    var dismissDelegate: DismissDelegate?
    
    
    private func add() {
    }
    private func newCategory() {
        Task {
            let newCategory = await EventsService.shared.createNewCategory(name: todoNewCategory)
            allCategories = await EventsService.shared.getCategories();
            todoCategoryId = todoNewCategory;
            todoNewCategoryPresented = false;
            todoNewCategory = ""
        }
    }
     func viewDidAppear() {
        
    }
    
    
    public var body: some View {
            VStack {
                Text("New To-Do Item").font(.title)
                HStack {
                    Picker("Category", selection: $todoCategoryId) {
                        Text("None").tag("None")
                        ForEach(allCategories ?? [], id: \.self) {category in
                            Text(category.name).tag(category.name)
                        }
                        Text("New Category").tag("New")
                    }.onChange(of: todoCategoryId, {
                        if (todoCategoryId == "New") {
                            todoNewCategoryPresented = true
                        }
                    })
                    .alert("Create a new category", isPresented: $todoNewCategoryPresented) {
                        TextField("ASSA", text: $todoNewCategory)
                        Button(action: newCategory) {
                            Text("OK")
                        }
                    }
                    Picker("Repeat", selection: $todoRepeat) {
                        ForEach(TodoRepeat.allCases, id: \.self) { item in
                            Text(item.rawValue)
                        }
                    }
                }
//                DatePicker("Due Date", selection: $todoDueDate, displayedComponents: [.date, .hourAndMinute])
//                HStack {
//                    Text("Remind Me")
//                    Picker("Remind Me", selection: $remindMeCategory) {
//                        Text("One hour before")
//                        Text("Two hours before")
//                        Text("The morning before")
//                    }
//                }
                Picker("What's this type of thing?", selection: $todoType) {
                    Text("To-Do").tag(TodoItemType.ToDo)
                    Text("Habit").tag(TodoItemType.Habit)
                }.pickerStyle(.segmented)
                HStack {
                    TextField("To-Do", text: $todoName)
                        .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/).stroke(Color.orange))
                        .focused($focused)
                    Spacer()
                    Button(action:
                            { 
                        Task {
                            EventsService.shared.createReminder(todoName: todoName, todoDueDate: nil, hasNotification: true)
                            presentationMode.wrappedValue.dismiss()
                        }
                        }
) {
                        Text("Add")
                    }
                    .buttonStyle(.borderedProminent)
                }
                Text("You will have 24 hours to do this task...")
            }
            .padding(15)
            .onAppear{
                focused = true
            }
        
            .modelContainer(for: Category.self)
            .onDisappear(perform: dismissDelegate?.didDismissSwiftUIView)
    }
}


import SwiftUI
import SwiftData
//struct NewTodoView: View {
//    @State private var name: String = ""
//    @State private var customCategory: String = ""
//    @State private var selectedCategory: String?;
//    @State private var todoNewCategorySelected = false;
//    @Query var categories: [Category] = EventsService.shared.getCategoriesSync()
//
//    var dismissDelegate: DismissDelegate?
//
//    init() {
//        name = ""
//        selectedCategory = nil;
//    }
//    private func newCategory() {
//    
//            Task {
//                let newCategory = await EventsService.shared.createNewCategory(name: customCategory)
////                categories = await EventsService.shared.getCategories();
//                selectedCategory = customCategory;
//                //                todoNewCategoryPresented = false;
//                customCategory = ""
//            }
//        }
//    var body: some View {
//        NavigationStack {
//            Form {
//                TextField("Item", text: $name)
//                
//                Picker("Category", selection: $selectedCategory) {
//                    Text("Select a category").tag(nil as Category?)
//                    ForEach(categories) { category in
//                        Text(category.name).tag(category.name)
//                    }
//                    Text("New Category").tag("New")
//                }.onChange(of: selectedCategory, perform: {
//                    selectedCategory in
//                    if (selectedCategory == "New") {
//                        todoNewCategorySelected = true
//                    }
//                })
//                Button(action:  {
//                }) {
//                    Text("Add")
//                }
//                
//            }
//            .alert("Create a new category", isPresented: $todoNewCategorySelected) {
//                                    TextField("ASSA", text: $customCategory)
//                                    Button(action: newCategory) {
//                                        Text("OK")
//                                    }
//                                }
//        }.modelContainer(for: Category.self)
//    }
//        
//}
