import mongoose from 'mongoose';
import Category from '../schemas/categorys.js';

class categoryModel {

    constructor() {
        // No necesitamos nada aquí
    }

    // OBTENER TODAS LAS CATEGORÍAS POR USUARIO
    async getAll(userId) {
        return await Category.find({ userId }).sort({ createdAt: -1 });
    }

    // OBTENER UNA CATEGORÍA POR ID
    async getOneById(id, userId) {
        return await Category.findOne({ _id: id, userId: userId });
    }

    // CREAR CATEGORÍA
    async create(data) {
        const category = new Category(data);
        return await category.save();
    }

    // ACTUALIZAR CATEGORÍA
    async update(id, data, userId) {
        return await Category.findOneAndUpdate(
            { _id: id, userId: userId },
            data,
            {
                returnDocument: 'after',
                runValidators: true
            }
        );
    }

    // ELIMINAR CATEGORÍA
    async delete(id, userId) {
        return await Category.findOneAndDelete({ _id: id, userId: userId });
    }

}

export default new categoryModel();