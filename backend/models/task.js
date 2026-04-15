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
    async getOneById(id) {
        return await Task.findById(id);
    }

    // CREAR TAREA
    async create(data) {
        const task = new Task(data);
        return await task.save();
    }

    // ACTUALIZAR TAREA
    async update(id, data) {
        return await Task.findByIdAndUpdate(
            id,
            data,
            {
                returnDocument: 'after',
                runValidators: true
            }
        );
    }

    // ELIMINAR TAREA
    async delete(id) {
        return await Task.findByIdAndDelete(id);
    }

}


export default new taskModel();