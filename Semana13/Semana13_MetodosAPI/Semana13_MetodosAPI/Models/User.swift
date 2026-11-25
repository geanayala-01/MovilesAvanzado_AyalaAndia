// Utilizando los métodos POST - PUT - DELETE

import Foundation

nonisolated struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
}
