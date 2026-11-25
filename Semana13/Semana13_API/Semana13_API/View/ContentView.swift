import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = UserViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // Campo de búsqueda
                TextField("Buscar usuario por nombre", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Lista de usuarios filtrados
                List(viewModel.filteredUsers) { user in
                    Text(user.name)
                }
            }
            .navigationTitle("Usuarios")
            .onAppear {
                // Llama a fetchUsers() del ViewModel, que realiza la petición a la API
                viewModel.fetchUsers()
            }
        }
    }
}

#Preview {
    ContentView()
}
