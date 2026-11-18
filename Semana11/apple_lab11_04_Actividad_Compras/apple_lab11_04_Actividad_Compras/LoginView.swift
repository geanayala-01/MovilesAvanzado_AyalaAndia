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
                // ① Logo y nombre (logo con anillo dorado)
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [dorado, Color(red: 1, green: 0.88, blue: 0.55)],
                                                    startPoint: .top, endPoint: .bottom))
                    .frame(width: 96, height: 96)
                    .background(.white.opacity(0.08), in: Circle())
                    .overlay(Circle().stroke(dorado.opacity(0.8), lineWidth: 1.5))
                    .shadow(color: dorado.opacity(0.4), radius: 18)
                Text("Compras")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                Text("TECSUP · DISTRIBUIDORA")
                    .font(.caption.weight(.semibold)).tracking(4)
                    .foregroundStyle(dorado)
                    .padding(.bottom, 24)

                // ② Usuario · ③ Clave oculta (campos de vidrio)
                CampoTexto(titulo: "Usuario", texto: $usuario, icono: "person", oscuro: true)
                CampoTexto(titulo: "Clave", texto: $clave, seguro: true, icono: "lock", oscuro: true)

                // ④ Mensaje de error genérico
                if error {
                    Label("Usuario o clave incorrectos", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color(red: 1, green: 0.55, blue: 0.5)).font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // ⑤ Ingresar (botón dorado)
                Button { ingresar() } label: {
                    Text("Ingresar")
                        .font(.headline)
                        .foregroundStyle(esmeraldaOscuro)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(LinearGradient(colors: [Color(red: 0.93, green: 0.80, blue: 0.42), dorado],
                                                   startPoint: .top, endPoint: .bottom),
                                    in: Capsule())
                        .shadow(color: dorado.opacity(0.45), radius: 12, y: 4)
                }
                .padding(.top, 6)

                // ⑥ Ir a Crear cuenta
                NavigationLink { RegistroView() } label: {
                    Text("¿Primera vez? ").foregroundStyle(.white.opacity(0.7)) + Text("Crear cuenta").bold().foregroundStyle(dorado)
                }
                .padding(.top, 4)

                Text("Demo: mtorres2 / rvega (Comprador) · supervisor (Supervisor) · clave 123456")
                    .font(.caption2).foregroundStyle(.white.opacity(0.45)).multilineTextAlignment(.center)
                    .padding(.top, 20)
            }
            .padding(28).padding(.top, 50)
        }
        .background {
            ZStack {
                LinearGradient(colors: [Color(red: 0.03, green: 0.27, blue: 0.21), esmeraldaOscuro, .black],
                               startPoint: .top, endPoint: .bottom)
                RadialGradient(colors: [dorado.opacity(0.25), .clear], center: .top, startRadius: 0, endRadius: 420)
            }
            .ignoresSafeArea()
        }
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
                CampoTexto(titulo: "Nombre completo", texto: $nombre, icono: "person.text.rectangle")          // ②
                CampoTexto(titulo: "Usuario", texto: $usuario, icono: "at")                 // ③
                if !usuarioNormalizado.isEmpty {
                    let ya = existe(usuarioNormalizado)
                    Label(ya ? "Ese usuario ya existe" : "Disponible",
                          systemImage: ya ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .font(.footnote).foregroundStyle(ya ? .red : .green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                CampoTexto(titulo: "Clave (mínimo 6 caracteres)", texto: $clave, seguro: true, icono: "lock")   // ④
                CampoTexto(titulo: "Confirmar clave", texto: $confirmar, seguro: true, icono: "lock.rotation")

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
        .background(FondoElegante())
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
    var icono = "textformat"
    var oscuro = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icono).foregroundStyle(oscuro ? dorado : verde).frame(width: 20)
            Group {
                if seguro {
                    SecureField("", text: $texto, prompt: Text(titulo).foregroundStyle(oscuro ? .white.opacity(0.5) : .secondary))
                        .textContentType(.oneTimeCode)
                } else {
                    TextField("", text: $texto, prompt: Text(titulo).foregroundStyle(oscuro ? .white.opacity(0.5) : .secondary))
                }
            }
            .foregroundStyle(oscuro ? .white : .primary)
        }
        .textInputAutocapitalization(titulo.hasPrefix("Nombre") ? .words : .never)
        .autocorrectionDisabled()
        .padding(16)
        .background(oscuro ? AnyShapeStyle(.white.opacity(0.08)) : AnyShapeStyle(.background),
                    in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(dorado.opacity(oscuro ? 0.45 : 0.3), lineWidth: 1))
    }
}
