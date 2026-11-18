//
//  ComprasApp.swift
//  Punto de entrada: crea el contenedor de SwiftData y decide Login o TabView.
//

import SwiftUI
import SwiftData

@main
struct ComprasApp: App {
    @State private var sesion = Sesion()

    // Contenedor persistente con las 4 clases @Model
    let container: ModelContainer = {
        do {
            let c = try ModelContainer(for: Usuario.self, Proveedor.self, Producto.self, Compra.self)
            print("Base de datos SQLite en: \(c.configurations.first?.url.path ?? "")")
            return c
        } catch {
            fatalError("Error al crear el ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RaizView()
                .environment(sesion)
                .tint(verde)
        }
        .modelContainer(container)
    }
}

// Si hay sesión muestra las pestañas del rol; si no, el login
struct RaizView: View {
    @Environment(Sesion.self) private var sesion
    @Environment(\.modelContext) private var ctx

    var body: some View {
        Group {
            if sesion.usuario == nil {
                NavigationStack { LoginView() }
            } else {
                PestanasView()
            }
        }
        .task { DatosIniciales.cargar(ctx) }
    }
}

// MARK: - TabView según el rol

struct PestanasView: View {
    @Environment(Sesion.self) private var sesion

    var body: some View {
        if sesion.esSupervisor {
            // Supervisor: Resumen, Aprobar, Por pagar, Productos, Proveedores
            TabView {
                Tab("Resumen", systemImage: "chart.bar.fill") { NavigationStack { ResumenView() } }
                Tab("Aprobar", systemImage: "checkmark.seal.fill") { NavigationStack { AprobarView() } }
                Tab("Por pagar", systemImage: "creditcard.fill") { NavigationStack { PorPagarView() } }
                Tab("Productos", systemImage: "shippingbox.fill") { NavigationStack { ProductosView() } }
                Tab("Proveedores", systemImage: "building.2.fill") { NavigationStack { ProveedoresView() } }
            }
        } else {
            // Comprador: Productos, Proveedores, Compra, Mis compras
            TabView {
                Tab("Productos", systemImage: "shippingbox.fill") { NavigationStack { ProductosView() } }
                Tab("Proveedores", systemImage: "building.2.fill") { NavigationStack { ProveedoresView() } }
                Tab("Compra", systemImage: "cart.badge.plus") { NavigationStack { NuevaCompraView() } }
                Tab("Mis compras", systemImage: "list.bullet.rectangle") { NavigationStack { MisComprasView() } }
            }
        }
    }
}

// MARK: - Cuenta: menú del avatar con Cerrar sesión (va en la barra de cada pantalla)

struct AvatarMenu: View {
    @Environment(Sesion.self) private var sesion

    var body: some View {
        Menu {
            Section("\(sesion.usuario?.nombre ?? "") · \(sesion.usuario?.rol ?? "")") {
                Text("Usuario: \(sesion.usuario?.usuario ?? "")")
                Button("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
                    sesion.usuario = nil
                }
            }
        } label: {
            Text(iniciales(sesion.usuario?.nombre ?? ""))
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(verde, in: Circle())
        }
    }
}

extension View {
    // Agrega el avatar de la sesión a la barra superior
    func conAvatar() -> some View {
        toolbar { ToolbarItem(placement: .topBarTrailing) { AvatarMenu() } }
    }
}

// MARK: - Piezas visuales reutilizables

struct Insignia: View {
    let texto: String
    let color: Color
    var body: some View {
        Text(texto)
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color, in: Capsule())
    }
}

struct Iniciales: View {
    let nombre: String
    var color: Color = verde
    var body: some View {
        Text(iniciales(nombre))
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background(color, in: RoundedRectangle(cornerRadius: 10))
    }
}

func colorEstado(_ c: Compra) -> Color {
    switch c.estado {
    case Estado.pendiente: return .orange
    case Estado.rechazada: return .red
    default: return .green
    }
}
