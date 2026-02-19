// Importamos mongoose para trabajar con ObjectId
import mongoose from 'mongoose';

// Importamos el modelo creado desde el schema
import User from '../schemas/user.js';

// Clase que maneja todas las operaciones de base de datos
class userModel {

    // CREAR USUARIO
    async create(data) {

        try {
            // data debe contener:
            // email, password, name
            return await User.create({
                email: data.email,
                password: data.password,
                name: data.name,
                createdAt: new Date(),
                updatedAt: new Date()
            });

        }
        catch (error) {
            throw error;
        }
    }

    // OBTENER TODOS LOS USUARIOS
    async getAll() {

        try {
            return await User.find();
        }
        catch (error) {
            throw error;
        }
    }

    // OBTENER USUARIO POR ID
    async getOneById(id) {
        try {
            return await User.findById(
                new mongoose.Types.ObjectId(id)
            );
        }
        catch (error) {
            throw error;
        }
    }

    // OBTENER USUARIO POR FILTRO
    // ejemplo: email
    async getOne(filtro) {

        try {
            return await User.findOne(filtro);
        }
        catch (error) {
            throw error;
        }
    }

    // ACTUALIZAR USUARIO
    async update(id, data) {
        try {
            return await User.findByIdAndUpdate(
                new mongoose.Types.ObjectId(id),
                {
                    email: data.email,
                    name: data.name,
                    password: data.password,
                    updatedAt: new Date()
                },
                {
                    new: true
                }
            )
        }
        catch (error) {
            throw error;
        }

    }

    // ELIMINAR USUARIO
    async delete(id) {
        try {
            return await User.findByIdAndDelete(
                new mongoose.Types.ObjectId(id)
            );
        }
        catch (error) {
            throw error;
        }
    }
}
// Exportamos el modelo
export default new userModel();