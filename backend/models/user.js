// ============================================================
// Modelo de Usuario (Capa de datos)
// ============================================================
// Esta clase contiene los métodos que interactúan directamente
// con MongoDB a través de Mongoose. Separa la lógica de
// base de datos de los controladores.
// ============================================================
import mongoose from 'mongoose';
import User from '../schemas/user.js';

class userModel {

    // Crea un nuevo usuario en la base de datos
    async create(data) {
        try {
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

    // Obtiene todos los usuarios
    async getAll() {
        try {
            return await User.find();
        }
        catch (error) {
            throw error;
        }
    }

    // Obtiene un usuario por su ID de MongoDB
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

    // Obtiene un usuario por un filtro (ej: { email: 'correo@ejemplo.com' })
    async getOne(filtro) {
        try {
            return await User.findOne(filtro);
        }
        catch (error) {
            throw error;
        }
    }

    // Actualiza los datos de un usuario por su ID
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
                { new: true } // Devuelve el documento actualizado
            )
        }
        catch (error) {
            throw error;
        }
    }

    // Elimina un usuario por su ID
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

// Exporta una instancia única (patrón Singleton)
export default new userModel();
