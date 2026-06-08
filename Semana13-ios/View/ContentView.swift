import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = UserViewModel()
    @State private var showingForm = false
    @State private var editingUser: User?
    @State private var newName = ""
    @State private var newEmail = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextField("Buscar usuario por nombre", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                List(viewModel.filteredUsers) { user in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name)
                            .font(.headline)
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteUser(id: user.id)
                            }
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }

                        Button {
                            editingUser = user
                            newName = user.name
                            newEmail = user.email
                            showingForm = true
                        } label: {
                            Label("Editar", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
                .listStyle(.plain)

                Button {
                    editingUser = nil
                    newName = ""
                    newEmail = ""
                    showingForm = true
                } label: {
                    Label("Agregar Usuario", systemImage: "plus")
                }
                .padding()
            }
            .navigationTitle("Usuarios")
            .onAppear {
                Task {
                    await viewModel.fetchUsers()
                }
            }
            .sheet(isPresented: $showingForm) {
                NavigationStack {
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
                                let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                                let trimmedEmail = newEmail.trimmingCharacters(in: .whitespacesAndNewlines)

                                guard !trimmedName.isEmpty else { return }

                                showingForm = false

                                if let user = editingUser {
                                    let updated = User(id: user.id, name: trimmedName, email: trimmedEmail)
                                    Task {
                                        await viewModel.updateUser(user: updated)
                                    }
                                } else {
                                    Task {
                                        await viewModel.createUser(name: trimmedName, email: trimmedEmail)
                                    }
                                }
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
