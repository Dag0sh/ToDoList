//
//  ExpiredTask.swift
//  todo
//
//  Created by Dagosh on 22.09.2025.
//

import SwiftUI

struct ExpiredTasksView: View {
    @State private var currentTodo = ""
    @State private var todos: [Item] = []
    @State private var starstate = false
    @State private var deadline = Date()
    @State private var deadlineon: Bool = false

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    
    var body: some View {
            NavigationView {
                
                let hasExpiredTodos = todos.contains { todo in
                    if let time = todo.istime {
                        return isExpired(time)
                    }
                    return false
                }
                VStack {
                    Spacer()
                    if hasExpiredTodos {
                        List {
                            ForEach(todos.indices.filter { index in
                                if let time = todos[index].istime {
                                    return isExpired(time)
                                }
                                return false
                            }, id: \.self) { index in
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 1){
                                        Text(todos[index].todo)
                                            .font(.system(size: 18))
                                        
                                        
                                        if let time = todos[index].istime{
                                            Text(time)
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Spacer()
                                    
                                    Button(action: {
                                        todos[index].starstate.toggle()
                                        self.save()
                                    }) {
                                        Image(systemName: todos[index].starstate ? "star.fill" : "star")
                                            .foregroundColor(todos[index].starstate ? .yellow : .gray)
                                    }
                                }
                                
                            }
                            .onDelete(perform: delete)
                        }}else {Text("Nothing to delete")
                                .font(.system(size: 24))
                                .frame(maxWidth: .infinity, alignment: .center)
                            Spacer()
                        }
                    Button(action: {
                                    todos.removeAll { todo in
                                        if let time = todo.istime {
                                            return isExpired(time)
                                        }
                                        return false
                                    }
                                    save()
                                }) {
                                    Text("Delete all")
                                        .foregroundColor(
                                                    todos.contains { todo in
                                                        if let time = todo.istime {
                                                            return isExpired(time)
                                                        }
                                                        return false
                                                    } ? .red : .gray
                                                )
                                }
                                .disabled(
                                    !todos.contains { todo in
                                        if let time = todo.istime {
                                            return isExpired(time)
                                        }
                                        return false
                                    }
                                )
                    
                }
                .navigationBarTitle("Past date")
            }.onAppear(perform: load)
                .onAppear(perform: save)
        }
    
    private func save() {
            UserDefaults.standard.set(
                try? PropertyListEncoder().encode(self.todos), forKey: "myTodosKey"
            )
        }
    
    private func load() {
        if let todosData = UserDefaults.standard.value(forKey: "myTodosKey")
            as? Data
        {
            if let todosList = try? PropertyListDecoder().decode(
                Array<Item>.self,
                from: todosData
            ) {
                self.todos = todosList
            }
        }
    }
    
    private func delete(at offset: IndexSet) {
        self.todos.remove(atOffsets: offset)
        save()
        }
    
    private func isExpired(timeString: String) -> Bool {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            
            guard let eventDate = dateFormatter.date(from: timeString) else {
                return false
            }
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            return eventDate < today
        }
}
