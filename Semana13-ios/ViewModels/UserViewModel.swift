import Combine
import Foundation
import SwiftUI

class UserViewModel: ObservableObject {

    @Published var users: [User] = []
    @Published var searchText: String = ""

    var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { user in
                user.name.lowercased().contains(searchText.lowercased())
            }
        }
    }

    func fetchUsers() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else {
            print("URL inválida")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in

            if let data = data {
                do {
                    let decodedUsers = try JSONDecoder().decode([User].self, from: data)

                    DispatchQueue.main.async {
                        self.users = decodedUsers
                    }
                } catch {
                    print("Error al decodificar: \(error)")
                }
            } else if let error = error {
                print("Error de red: \(error)")
            }

        }.resume()
    }

    func addUser(name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let newId = (users.map { $0.id }.max() ?? 0) + 1
        let newUser = User(id: newId, name: trimmedName, email: "")
        users.append(newUser)
    }

    func addUser(name: String, email: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let newId = (users.map { $0.id }.max() ?? 0) + 1
        let newUser = User(id: newId, name: trimmedName, email: trimmedEmail)
        users.append(newUser)
    }

    func updateUser(user: User, newName: String, newEmail: String) {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        if let index = users.firstIndex(of: user) {
            users[index].name = trimmedName
            users[index].email = trimmedEmail
        }
    }

    func deleteUser(_ user: User) {
        users.removeAll { $0 == user }
    }
}
