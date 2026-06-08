import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = UserViewModel()
    @State private var showingForm = false
    @State private var editingUser: User?
    @State private var newName = ""
    @State private var newEmail = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextField("Buscar usuario", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                List {
                    ForEach(viewModel.filteredUsers) { user in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name)
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingUser = user
                            newName = user.name
                            newEmail = user.email
                            showingForm = true
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let user = viewModel.filteredUsers[index]
                            viewModel.deleteUser(user)
                        }
                    }
                }

                Button("Agregar Usuario") {
                    editingUser = nil
                    newName = ""
                    newEmail = ""
                    showingForm = true
                }
                .padding()
            }
            .navigationTitle("Usuarios")
            .onAppear {
                viewModel.fetchUsers()
            }
            .sheet(isPresented: $showingForm) {
                NavigationView {
                    Form {
                        Section {
                            TextField("Nombre", text: $newName)
                            TextField("Email", text: $newEmail)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                    }
                    .navigationTitle(editingUser == nil ? "Nuevo Usuario" : "Editar Usuario")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancelar") {
                                showingForm = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Guardar") {
                                if let user = editingUser {
                                    viewModel.updateUser(user: user, newName: newName, newEmail: newEmail)
                                } else {
                                    viewModel.addUser(name: newName, email: newEmail)
                                }
                                showingForm = false
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
