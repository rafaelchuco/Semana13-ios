import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: Int
    var name: String
    var email: String
}
