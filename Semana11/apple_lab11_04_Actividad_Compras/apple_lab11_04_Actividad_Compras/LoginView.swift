//
//  LoginView.swift
//  B1 · Login y B2 · Crear cuenta
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(Sesion.self) private var sesion
    @Environment(\.modelContext) private var ctx
    @State private var usuario = ""
    @State private var clave = ""
    @State private var error = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // ① Logo y nombre
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(.white)
                    .frame(width: 90, height: 90)
                    .background(LinearGradient(colors: [verde, .teal], startPoint: .top, endPoint: .bottom),
                                in: RoundedRectangle(cornerRadius: 22))
                Text("Compras Tecsup").font(.largeTitle.bold())
                Text("Inicia sesión para continuar").foregroundStyle(.secondary)
                    .padding(.bottom, 16)

                // ② Usuario · ③ Clave oculta
                CampoTexto(titulo: "Usuario", texto: $usuario)
                CampoTexto(titulo: "Clave", texto: $clave, seguro: true)

                // ④ Mensaje de error genérico
                if error {
                    Label("Usuario o clave incorrectos", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red).font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // ⑤ Ingresar
                Button { ingresar() } label: {
                    Text("Ingresar").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent).controlSize(.large)

                // ⑥ Ir a Crear cuenta
                NavigationLink("¿Primera vez? Crear cuenta") { RegistroView() }

                Text("Demo: mtorres2 / rvega (Comprador) · supervisor (Supervisor) · clave 123456")
                    .font(.caption).foregroundStyle(.tertiary).multilineTextAlignment(.center)
            }
            .padding(24).padding(.top, 30)
        }
        .background(Color(.systemGroupedBackground))
    }

    func ingresar() {
        let u = usuario.trimmingCharacters(in: .whitespaces).lowercased()
        let c = clave
        // #Predicate: usuario guardado en minúsculas y clave exacta
        let descriptor = FetchDescriptor<Usuario>(predicate: #Predicate { $0.usuario == u && $0.clave == c })
        if let encontrado = try? ctx.fetch(descriptor).first {
            error = false
            sesion.usuario = encontrado
        } else {
            error = true
        }
    }
}

struct RegistroView: View {
    @Environment(Sesion.self) private var sesion
    @Environment(\.modelContext) private var ctx
    @State private var nombre = ""
    @State private var usuario = ""
    @State private var clave = ""
    @State private var confirmar = ""
    @State private var rol = Rol.comprador
    @State private var error: String?

    // ③ Usuario único sin distinguir mayúsculas (se guarda en minúsculas)
    var usuarioNormalizado: String { usuario.trimmingCharacters(in: .whitespaces).lowercased() }

    func existe(_ u: String) -> Bool {
        let d = FetchDescriptor<Usuario>(predicate: #Predicate { $0.usuario == u })
        return ((try? ctx.fetchCount(d)) ?? 0) > 0
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                CampoTexto(titulo: "Nombre completo", texto: $nombre)          // ②
                CampoTexto(titulo: "Usuario", texto: $usuario)                 // ③
                if !usuarioNormalizado.isEmpty {
                    let ya = existe(usuarioNormalizado)
                    Label(ya ? "Ese usuario ya existe" : "Disponible",
                          systemImage: ya ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .font(.footnote).foregroundStyle(ya ? .red : .green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                CampoTexto(titulo: "Clave (mínimo 6 caracteres)", texto: $clave, seguro: true)   // ④
                CampoTexto(titulo: "Confirmar clave", texto: $confirmar, seguro: true)

                // ⑤ Rol
                Text("TU ROL").font(.caption).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Picker("Rol", selection: $rol) {
                    Text(Rol.comprador).tag(Rol.comprador)
                    Text(Rol.supervisor).tag(Rol.supervisor)
                }
                .pickerStyle(.segmented)

                if let error {
                    Text(error).foregroundStyle(.red).font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // ⑥ Registrarme (entra directo)
                Button { registrar() } label: { Text("Registrarme").frame(maxWidth: .infinity) }
                    .buttonStyle(.borderedProminent).controlSize(.large)

                Text("Al registrarte entrarás directamente a la app con las pestañas de tu rol.")
                    .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Crear cuenta")              // ① Título (y "< Atrás" al login)
        .navigationBarTitleDisplayMode(.inline)
    }

    func registrar() {
        let n = nombre.trimmingCharacters(in: .whitespaces)
        let u = usuarioNormalizado
        if n.isEmpty || u.isEmpty { error = "Completa nombre y usuario."; return }
        if existe(u) { error = "El usuario \"\(u)\" ya existe."; return }
        if clave.count < 6 { error = "La clave debe tener mínimo 6 caracteres."; return }
        if clave != confirmar { error = "Las claves no coinciden."; return }

        let nuevo = Usuario(nombre: n, usuario: u, clave: clave, rol: rol)
        ctx.insert(nuevo)
        try? ctx.save()
        sesion.usuario = nuevo
    }
}

struct CampoTexto: View {
    let titulo: String
    @Binding var texto: String
    var seguro = false

    var body: some View {
        Group {
            if seguro { SecureField(titulo, text: $texto).textContentType(.oneTimeCode) }
            else { TextField(titulo, text: $texto) }
        }
        .textInputAutocapitalization(titulo.hasPrefix("Nombre") ? .words : .never)
        .autocorrectionDisabled()
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}
