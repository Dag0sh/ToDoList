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

            VStack {
                Text(" ")
                Spacer()
                if todos.contains(where: { $0.deadlineStatus }) {
                    List {
                        Section(
                            header:
                                Text("No time left😔")
                                .font(.headline)
                        ) {
                            ForEach(
                                todos.filter { $0.deadlineStatus },
                                id: \.id
                            ) { todo in

                                HStack {
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(todo.toDo)
                                            .font(.system(size: 18))

                                        if let time = todo.deadline {
                                            Text(time)
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Spacer()

                                    Button(action: {
                                        if let i = todos.firstIndex(where: {
                                            $0.id == todo.id
                                        }) {
                                            todos[i].starState.toggle()
                                            save()
                                        }
                                    }) {
                                        Image(
                                            systemName: todo.starState
                                                ? "star.fill" : "star"
                                        )
                                        .foregroundColor(
                                            todo.starState ? .yellow : .gray
                                        )
                                    }
                                }
                            }

                            .onDelete(perform: delete)
                        }
                    }
                } else {
                    Text("Nothing to delete")
                        .font(.system(size: 24))
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                }
                Button(action: {
                    todos.removeAll { $0.deadlineStatus }
                    save()
                }) {
                    Text("Delete all")
                        .foregroundColor(
                            todos.contains(where: { $0.deadlineStatus })
                                ? .red : .gray
                        )
                }
                .disabled(!todos.contains(where: { $0.deadlineStatus }))

            }
            .navigationBarTitle("Past date", displayMode: .large)
        }.onAppear(perform: load)
            .onAppear(perform: updateDeadlineStatuses)
    }

    private func updateDeadlineStatuses() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for index in todos.indices {
            if let deadlineString = todos[index].deadline,
                let deadlineDate = dateFormatter.date(from: deadlineString)
            {
                let normalizedDeadlineDate = calendar.startOfDay(
                    for: deadlineDate
                )
                todos[index].deadlineStatus = normalizedDeadlineDate < today
            } else {
                todos[index].deadlineStatus = false
            }
        }
    }

    private func save() {
        UserDefaults.standard.set(
            try? PropertyListEncoder().encode(self.todos),
            forKey: "mytoDosKey"
        )
    }

    private func load() {
        if let todosData = UserDefaults.standard.value(forKey: "mytoDosKey")
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
}
