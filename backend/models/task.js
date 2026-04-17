import mongoose from 'mongoose';
import taskSchema from '../schemas/tasks.js'

// Creamos el modelo base de Mongoose
const Task = mongoose.model('Task', taskSchema);


class taskModel {

    constructor() {
        // No necesitamos nada aquí
    }

    // OBTENER TODAS LAS TAREAS (con filtros)
    async getAll(filters = {}) {
        return await Task.find(filters).sort({ createdAt: -1 });
    }

    // OBTENER UNA TAREA POR ID
    async getOneById(id, userId) {
        return await Task.findOne({ _id: id, userId: userId });
    }

    // CREAR TAREA
    async create(data) {
        const task = new Task(data);
        return await task.save();
    }

    // ACTUALIZAR TAREA
    async update(id, data, userId) {
        return await Task.findOneAndUpdate(
            { _id: id, userId: userId },
            data,
            {
                returnDocument: 'after',
                runValidators: true
            }
        );
    }

    // ELIMINAR TAREA
    async delete(id, userId) {
        return await Task.findOneAndDelete({ _id: id, userId: userId });
    }

}


export default new taskModel();