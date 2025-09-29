import Foundation
import SwiftUI

struct ContentView: View {
    @State private var currentTodo = ""
    @State private var toDos: [Item] = []
    @State private var starState = false
    @State private var deadline = Date()
    @State private var deadlineOn: Bool = false
    @State private var editingItem: Item? = nil
    @State private var editedText: String = ""
    @State private var editedDeadline: Date = Date()
    @State private var editedHasDeadline: Bool = false

    enum sortState: String {
        case recent = "Recent calls"
        case importance = "Important tasks"
        case nearestDeadline = "Nearest deadline"

    }

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    @State private var sortBy: sortState = .recent

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    var newitem = Item(
                        toDo: "",
                        starState: false,
                        deadlineStatus: false,
                        createTime: Date.now
                    )
                    HStack {
                        TextField("New toDo..", text: $currentTodo)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button(action: {
                            guard !self.currentTodo.isEmpty else { return }
                            newitem.toDo = currentTodo
                            if deadlineOn {
                                let adjustedDeadline = max(deadline, Date())
                                newitem.deadline = dateFormatter.string(
                                    from: adjustedDeadline
                                )
                                deadline = Date()
                            }
                            self.toDos.insert(newitem, at: 0)
                            self.currentTodo = ""
                            self.save()
                        }) {
                            Image(systemName: "plus.app")
                        }.disabled(currentTodo.isEmpty)

                            .padding(.leading, 5)
                    }
                    Toggle("Enable deadline", isOn: $deadlineOn)
                        .padding()
                    if deadlineOn {
                        DatePicker(
                            "Выберите дедлайн",
                            selection: $deadline,
                            in: Date()...,
                            displayedComponents: [.date]
                        )
                        .labelsHidden()
                        .padding(.leading, 10)
                    }
                }.padding()
                List {
                    Section(
                        header:
                            HStack {
                                Text(sortBy.rawValue)
                                    .font(.headline)

                                Spacer()

                                HStack(spacing: 8) {
                                    Button(action: {
                                        sortBy = .nearestDeadline
                                        save()
                                    }) {
                                        Text("d")
                                            .font(
                                                .system(size: 14, weight: .bold)
                                            )
                                            .foregroundColor(
                                                sortBy == .nearestDeadline
                                                    ? .blue : .gray
                                            )
                                    }

                                    Text("|")
                                        .foregroundColor(.gray)

                                    Button(action: {
                                        sortBy = .importance
                                        save()
                                    }) {
                                        Text("I")
                                            .font(
                                                .system(size: 14, weight: .bold)
                                            )
                                            .foregroundColor(
                                                sortBy == .importance
                                                    ? .blue : .gray
                                            )
                                    }

                                    Text("|")
                                        .foregroundColor(.gray)

                                    Button(action: {
                                        sortBy = .recent
                                        save()
                                    }) {
                                        Text("r")
                                            .font(
                                                .system(size: 14, weight: .bold)
                                            )
                                            .foregroundColor(
                                                sortBy == .recent
                                                    ? .blue : .gray
                                            )
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(6)
                            }
                            .padding(.top, 0)

                    ) {
                        ForEach(toDos.indices, id: \.self) { index in
                            HStack {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(toDos[index].toDo)
                                        .font(.system(size: 18))

                                    if let time = toDos[index].deadline {

                                        let date =
                                            dateFormatter.date(from: time)
                                            ?? Date()

                                        Text(time)
                                            .foregroundColor(
                                                Calendar.current.isDate(
                                                    date,
                                                    inSameDayAs: Date()
                                                )
                                                    ? .gray
                                                    : (date < Date()
                                                        ? .red : .gray)
                                            )
                                    }
                                }
                                Spacer()

                                Button(action: {
                                    toDos[index].starState.toggle()
                                    self.save()
                                }) {
                                    Image(
                                        systemName: toDos[index].starState
                                            ? "star.fill" : "star"
                                    )
                                    .foregroundColor(
                                        toDos[index].starState ? .yellow : .gray
                                    )
                                }
                            }.swipeActions(edge: .trailing) {

                                Button(role: .destructive) {
                                    delete(at: IndexSet(integer: index))
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    editedText = toDos[index].toDo
                                    if let deadlineString = toDos[index]
                                        .deadline,
                                        let date = dateFormatter.date(
                                            from: deadlineString
                                        )
                                    {
                                        editedDeadline = date < Date() ? Date() : date
                                        editedHasDeadline = true
                                    } else {
                                        editedDeadline = Date()
                                        editedHasDeadline = false
                                    }
                                    editingItem = toDos[index]
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.green)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("toDo List", displayMode: .large)
            .sheet(item: $editingItem) { item in
                NavigationView {
                    Form {
                        Section(header: Text("Task")) {
                            TextField("Task", text: $editedText)
                        }
                        Section(header: Text("Deadline")) {
                            Toggle("Enable deadline", isOn: $editedHasDeadline)

                            if editedHasDeadline {
                                DatePicker(
                                    "Select deadline",
                                    selection: $editedDeadline,
                                    in: Date()...,
                                    displayedComponents: [.date]
                                )
                            }
                        }
                    }.navigationBarTitle("Edit Task", displayMode: .large)
                        .navigationBarItems(
                            leading: Button("Cancel") {
                                editingItem = nil
                            },
                            trailing: Button("Save") {
                                saveEditedItem()
                                editingItem = nil
                            }
                            .disabled(editedText.isEmpty)
                        )
                }
                .navigationBarTitle("Edit Task", displayMode: .large)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        editingItem = nil
                    },
                    trailing: Button("Save") {
                        saveEditedItem()
                        editingItem = nil
                    }
                    .disabled(editedText.isEmpty)
                )
            }
        }.onAppear(perform: load)
            .onAppear(perform: updateDeadlineStatuses)
    }

    private func updateDeadlineStatuses() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for index in toDos.indices {
            if let deadlineString = toDos[index].deadline,
                let deadlineDate = dateFormatter.date(from: deadlineString)
            {
                let normalizedDeadlineDate = calendar.startOfDay(
                    for: deadlineDate
                )
                toDos[index].deadlineStatus = normalizedDeadlineDate < today
            } else {
                toDos[index].deadlineStatus = false
            }
        }
    }

    private func saveEditedItem() {
        guard let editingItem = editingItem,
            let index = toDos.firstIndex(where: { $0.id == editingItem.id })
        else { return }

        toDos[index].toDo = editedText
        if editedHasDeadline {
            toDos[index].deadline = dateFormatter.string(from: editedDeadline)
        } else {
            toDos[index].deadline = nil
        }

        save()
    }

    private func sortByRecent() {
        self.toDos.sort {
            return $0.createTime > $1.createTime
        }
    }

    private func sortByImportance() {
        self.toDos.sort { $0.starState && !$1.starState }
    }

    private func sortByDeadline() {
        sortByImportance()

        self.toDos.sort { item1, item2 in
            switch (item1.deadlineStatus, item2.deadlineStatus) {
            case (true, false):
                return false
            case (false, true):
                return true
            default:
                if let date1 = item1.deadline, let date2 = item2.deadline,
                    let date1 = dateFormatter.date(from: date1),
                    let date2 = dateFormatter.date(from: date2)
                {
                    return date1 < date2
                }
                if item1.deadline != nil && item2.deadline == nil {
                    return true
                }
                if item1.deadline == nil && item2.deadline != nil {
                    return false
                }
                return false
            }
        }
    }

    private func save() {
        UserDefaults.standard.set(
            try? PropertyListEncoder().encode(self.toDos),
            forKey: "mytoDosKey"
        )
        updateDeadlineStatuses()
        switch sortBy {
        case .recent:
            sortByRecent()
        case .importance:
            sortByImportance()
        case .nearestDeadline:
            sortByDeadline()
        }
    }

    private func load() {
        if let toDosData = UserDefaults.standard.value(forKey: "mytoDosKey")
            as? Data
        {
            if let toDosList = try? PropertyListDecoder().decode(
                Array<Item>.self,
                from: toDosData
            ) {
                self.toDos = toDosList
            }
        }

    }

    private func delete(at offset: IndexSet) {
        self.toDos.remove(atOffsets: offset)
        save()
    }

}

#Preview {
    ContentView()
}
