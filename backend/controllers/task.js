import taskModel from '../models/task.js';

class taskControllers {

    constructor() {
        // No inicializamos nada por ahora
    }

    // OBTENER TODAS LAS TAREAS
    async getAll(req, res) {
        try {
            const { status, priority, categoryId } = req.query;

            const filters = {};

            if (status) filters.status = status;
            if (priority) filters.priority = priority;
            if (categoryId) filters.categoryId = categoryId;

            if (req.user) {
                filters.userId = req.user._id;
            }

            const tasks = await taskModel.getAll(filters);

            res.status(200).json({
                tasks: tasks
            });

        } catch (error) {

            console.log(error);

            res.status(500).json({
                error: "Error al obtener tareas"
            });

        }
    }

    // OBTENER TAREA POR ID
    async getOneById(req, res) {
        try {

            const { id } = req.params;

            const task = await taskModel.getOneById(id, req.user._id);

            if (!task) {
                return res.status(404).json({
                    error: "Tarea no encontrada"
                });
            }

            res.status(200).json({
                task: task
            });

        } catch (error) {

            res.status(500).json({
                error: "Error al obtener tarea"
            });

        }
    }

    // CREAR TAREA
    async create(req, res) {
        try {
            const {
                title,
                description,
                status,
                priority,
                dueDate,
                categoryId
            } = req.body;

            if (!title || !categoryId) {
                return res.status(400).json({
                    error: "Campos obligatorios faltantes"
                });
            }

            const newTask = await taskModel.create({

                title,
                description,
                status,
                priority,
                dueDate,
                categoryId,
                userId: req.user._id

            });

            res.status(201).json({
                task: newTask
            });

        } catch (error) {

            console.log(error);

            res.status(500).json({
                error: "Error al crear tarea"
            });

        }
    }

    // ACTUALIZAR TAREA
    async update(req, res) {
        try {

            const { id } = req.params;

            const task = await taskModel.update(id, req.body, req.user._id);

            if (!task) {
                return res.status(404).json({
                    error: "Tarea no encontrada"
                });
            }

            res.status(200).json({
                task: task
            });

        } catch (error) {

            res.status(500).json({
                error: "Error al actualizar tarea"
            });

        }
    }

    // ELIMINAR TAREA
    async delete(req, res) {
        try {

            const { id } = req.params;

            const task = await taskModel.delete(id, req.user._id);

            if (!task) {
                return res.status(404).json({
                    error: "Tarea no encontrada"
                });
            }

            res.status(200).json({
                message: "Tarea eliminada"
            });

        } catch (error) {

            res.status(500).json({
                error: "Error al eliminar tarea"
            });

        }
    }
}

export default new taskControllers();