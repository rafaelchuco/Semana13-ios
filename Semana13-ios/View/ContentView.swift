import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = UserViewModel()

    var body: some View {
        NavigationView {
            VStack {

                TextField("Buscar usuario por nombre", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                List(viewModel.filteredUsers) { user in
                    Text(user.name)
                }
            }
            .navigationTitle("Usuarios")
            .onAppear {
                viewModel.fetchUsers()
            }
        }
    }
}

#Preview {
    ContentView()
}
