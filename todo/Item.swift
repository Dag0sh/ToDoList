import Foundation

struct Item: Identifiable, Codable {
    let id = UUID()
    var toDo: String
    var starState: Bool
    var deadline: String?
    var createTime: Date
}
