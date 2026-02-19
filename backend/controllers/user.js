// Importamos la función que genera el token JWT
import { generarToken } from '../helpers/autetication.js';

// Importamos el modelo de usuario (Mongoose)
import userModel from '../models/user.js';

// Importamos bcrypt para encriptar contraseñas
import bcrypt from 'bcrypt';

// Clase que contiene todos los controladores de usuario
class userControllers {
    constructor() {
        // No necesitamos inicializar nada por ahora
    }

    // REGISTRAR USUARIO
    async register(req, res) {

        try {
            // Extraemos los datos enviados desde el cliente
            const { email, name, password } = req.body;

            // Verificamos si el usuario ya existe en la base de datos
            const usuarioExiste = await userModel.getOne({ email });

            if (usuarioExiste) {
                return res.status(400).json({
                    error: "El usuario ya existe"
                });
            }

            // Encriptamos la contraseña usando bcrypt
            const passwordEncryptado = await bcrypt.hash(password, 10);

            // Creamos el usuario en la base de datos
            const data = await userModel.create({

                email: email,
                name: name,
                password: passwordEncryptado

            });

            // Generamos el token JWT
            const token = generarToken(data.email);

            // Respondemos con status 201 (creado)
            res.status(201).json({
                user: data,
                token: token
            });

        }
        catch (error) {
            console.log(error);
            res.status(500).json({
                error: "Error al registrar usuario"
            });

        }

    }

    // LOGIN DE USUARIO
    async login(req, res) {

        try {
            // Obtenemos los datos enviados
            const { email, password } = req.body;

            // Buscamos el usuario en la base de datos
            const usuarioExiste = await userModel.getOne({ email });

            // Si no existe el usuario
            if (!usuarioExiste) {

                return res.status(400).json({
                    error: "El usuario no existe"
                });
            }

            // Comparamos la contraseña enviada con la encriptada
            const passwordValido = await bcrypt.compare(
                password,
                usuarioExiste.password
            );

            // Si la contraseña es incorrecta
            if (!passwordValido) {

                return res.status(400).json({
                    error: "Contraseña incorrecta"
                });
            }

            // Generamos el token JWT
            const token = generarToken(usuarioExiste.email);

            // Respondemos con el token
            res.status(200).json({
                user: usuarioExiste,
                token: token
            });

        }
        catch (error) {

            console.log(error);

            res.status(500).json({
                error: "Error en login"
            });

        }
    }

    // PERFIL DE USUARIO (GET /api/auth/me)
    async me(req, res) {

        try {
            // El email viene desde el middleware de autenticación
            const email = req.emailConectado;

            // Buscamos el usuario
            const usuario = await userModel.getOne({ email });

            // Respondemos con los datos
            res.status(200).json({ user: usuario });
        }
        catch (error) {

            res.status(500).json({
                error: "Error al obtener perfil"
            });

        }

    }



    // OBTENER TODOS LOS USUARIOS
    async getAll(req, res) {
        try {
            const usuarios = await userModel.getAll();
            res.status(200).json(usuarios);
        }
        catch (error) {
            res.status(500).json({
                error: "Error al obtener usuarios"
            });
        }
    }



    // OBTENER UN USUARIO POR ID
    async getOneById(req, res) {
        try {

            const { id } = req.params;

            const usuario = await userModel.getOneById(id);

            res.status(200).json(usuario);
        }
        catch (error) {

            res.status(500).json({
                error: "Error al obtener usuario"
            });
        }
    }



    // ACTUALIZAR USUARIO
    async update(req, res) {

        try {
            const { id } = req.params;
            const usuario = await userModel.update(id, req.body);
            res.status(200).json(usuario);
        }
        catch (error) {
            res.status(500).json({
                error: "Error al actualizar usuario"
            });
        }
    }

    // ELIMINAR USUARIO
    async delete(req, res) {
        try {
            const { id } = req.params;
            await userModel.delete(id);

            res.status(200).json({
                msg: "Usuario eliminado"
            });
        }
        catch (error) {

            res.status(500).json({
                error: "Error al eliminar usuario"
            });
        }
    }
}

// Exportamos una instancia de la clase
export default new userControllers();
