// Métodos GET - POST - PUT - DELETE con async/await

import Foundation

nonisolated struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
}
