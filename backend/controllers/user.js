// ============================================================
// Controlador de Usuario (Lógica de negocio)
// ============================================================
// Cada método corresponde a una ruta HTTP y contiene la lógica
// necesaria: validar datos, llamar al modelo, generar tokens JWT
// y enviar la respuesta al cliente.
// ============================================================
import { generarToken } from '../helpers/autetication.js';
import userModel from '../models/user.js';
import bcrypt from 'bcrypt';

class userControllers {
    constructor() {
        // No necesitamos inicializar nada por ahora
    }

    // ================================================================
    // REGISTRO DE USUARIO
    // POST /api/auth/register
    // Recibe: { email, name, password }
    // Responde: { user, token }
    // ================================================================
    async register(req, res) {
        try {
            const { email, name, password } = req.body;

            // Verifica si el email ya está registrado
            const usuarioExiste = await userModel.getOne({ email });
            if (usuarioExiste) {
                return res.status(400).json({ error: "El usuario ya existe" });
            }

            // Encripta la contraseña con bcrypt (10 rondas de sal)
            const passwordEncryptado = await bcrypt.hash(password, 10);

            // Crea el usuario en MongoDB
            const data = await userModel.create({
                email, name, password: passwordEncryptado
            });

            // Genera el token JWT para iniciar sesión automáticamente
            const token = generarToken(data.email);

            res.status(201).json({ user: data, token });

        } catch (error) {
            console.log(error);
            res.status(500).json({ error: "Error al registrar usuario" });
        }
    }

    // ================================================================
    // INICIO DE SESIÓN
    // POST /api/auth/login
    // Recibe: { email, password }
    // Responde: { user, token }
    // ================================================================
    async login(req, res) {
        try {
            console.log('Login attempt:', req.body);
            const { email, password } = req.body;

            // Busca el usuario por email
            const usuarioExiste = await userModel.getOne({ email });
            console.log('User found:', !!usuarioExiste);

            if (!usuarioExiste) {
                return res.status(400).json({ error: "El usuario no existe" });
            }

            // Compara la contraseña ingresada con la almacenada (encriptada)
            const passwordValido = await bcrypt.compare(
                password, usuarioExiste.password
            );
            console.log('Password valid:', passwordValido);

            if (!passwordValido) {
                return res.status(400).json({ error: "Contraseña incorrecta" });
            }

            // Genera el token JWT (válido por 7 días)
            const token = generarToken(usuarioExiste.email);
            console.log('Token generated:', !!token);

            res.status(200).json({ user: usuarioExiste, token });

        } catch (error) {
            console.log(error);
            res.status(500).json({ error: "Error en login" });
        }
    }

    // ================================================================
    // PERFIL DEL USUARIO AUTENTICADO
    // GET /api/auth/me  (requiere token)
    // Responde: { user }
    // ================================================================
    async me(req, res) {
        try {
            const email = req.emailConectado; // Viene del middleware verificarToken
            const usuario = await userModel.getOne({ email });
            res.status(200).json({ user: usuario });
        } catch (error) {
            res.status(500).json({ error: "Error al obtener perfil" });
        }
    }

    // ================================================================
    // OBTENER TODOS LOS USUARIOS
    // GET /api/auth
    // ================================================================
    async getAll(req, res) {
        try {
            const usuarios = await userModel.getAll();
            res.status(200).json(usuarios);
        } catch (error) {
            res.status(500).json({ error: "Error al obtener usuarios" });
        }
    }

    // ================================================================
    // OBTENER USUARIO POR ID
    // GET /api/auth/:id
    // ================================================================
    async getOneById(req, res) {
        try {
            const { id } = req.params;
            const usuario = await userModel.getOneById(id);
            res.status(200).json(usuario);
        } catch (error) {
            res.status(500).json({ error: "Error al obtener usuario" });
        }
    }

    // ================================================================
    // ACTUALIZAR USUARIO
    // PUT /api/auth/:id
    // ================================================================
    async update(req, res) {
        try {
            const { id } = req.params;
            const usuario = await userModel.update(id, req.body);
            res.status(200).json(usuario);
        } catch (error) {
            res.status(500).json({ error: "Error al actualizar usuario" });
        }
    }

    // ================================================================
    // ELIMINAR USUARIO
    // DELETE /api/auth/:id
    // ================================================================
    async delete(req, res) {
        try {
            const { id } = req.params;
            await userModel.delete(id);
            res.status(200).json({ msg: "Usuario eliminado" });
        } catch (error) {
            res.status(500).json({ error: "Error al eliminar usuario" });
        }
    }
}

// Exporta una instancia única (patrón Singleton)
export default new userControllers();
