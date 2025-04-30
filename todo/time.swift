//
//  time.swift
//  todo
//
//  Created by Dagosh on 26.04.2025.
//

import SwiftUI

struct time: View {
    @State private var currentTodo = ""
    @State private var todos: [Item] = []
    @State private var starstate = false
    @State private var deadline = Date()
    @State private var deadlineon: Bool = false
    
    
    
    private func sortirovkaimportant(){
        self.todos.sort {$0.starstate && !$1.starstate}
    }
    
    private func sortbytime(){
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            
            self.todos.sort { item1, item2 in
                if let dateString1 = item1.istime, let dateString2 = item2.istime {
                    if let date1 = dateFormatter.date(from: dateString1), let date2 = dateFormatter.date(from: dateString2) {
                        return date1 < date2
                    }
                }
                if item1.istime != nil && item2.istime == nil {
                    return true
                }
                if item1.istime == nil && item2.istime != nil {
                    return false
                }
                return false
            }
    }
    
    private func save() {
        UserDefaults.standard.set(
            try? PropertyListEncoder().encode(self.todos), forKey: "myTodosKey"
        )
        sortirovkaimportant()
        sortbytime()
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private func load() {
        if let todosData = UserDefaults.standard.value(forKey: "myTodosKey") as? Data {
            if let todosList
                = try? PropertyListDecoder().decode(Array<Item>.self, from: todosData) {
                self.todos = todosList
            }
        }
    }
    
    private func delete(at offset: IndexSet) {
    self.todos.remove(atOffsets: offset)
    save()
    }

   
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                        ForEach(todos.indices, id: \.self) { index in
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
                    }
            }
            .navigationBarTitle("Upcoming events")
        }.onAppear(perform: load)
            .onAppear(perform: save)
    }
}


#Preview {
    time()
}
