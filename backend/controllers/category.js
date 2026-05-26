import categoryModel from '../models/category.js';
import taskModel from '../models/task.js';

class categoryControllers {

    constructor() {
        // No inicializamos nada por ahora
    }

    // OBTENER TODAS LAS CATEGORÍAS
    async getAll(req, res) {
        try {
            const categories = await categoryModel.getAll(req.user._id);

            res.status(200).json({
                categories: categories
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                error: "Error al obtener categorías"
            });
        }
    }

    // OBTENER CATEGORÍA POR ID
    async getOneById(req, res) {
        try {
            const { id } = req.params;

            const category = await categoryModel.getOneById(id, req.user._id);

            if (!category) {
                return res.status(404).json({
                    error: "Categoría no encontrada"
                });
            }

            // Obtener tareas asociadas a la categoría
            const tasks = await taskModel.getAll({ categoryId: id, userId: req.user._id });

            res.status(200).json({
                category: category,
                tasks: tasks
            });

        } catch (error) {
            res.status(500).json({
                error: "Error al obtener categoría"
            });
        }
    }

    // CREAR CATEGORÍA
    async create(req, res) {
        try {
            const { name, color, icon } = req.body;

            if (!name || !color) {
                return res.status(400).json({
                    error: "Campos obligatorios faltantes"
                });
            }

            const newCategory = await categoryModel.create({
                name,
                color,
                icon,
                userId: req.user._id
            });

            res.status(201).json({
                category: newCategory
            });

        } catch (error) {
            console.log(error);
            res.status(500).json({
                error: "Error al crear categoría"
            });
        }
    }

    // ACTUALIZAR CATEGORÍA
    async update(req, res) {
        try {
            const { id } = req.params;
            const { name, color, icon } = req.body;

            const updates = {};
            if (name !== undefined) updates.name = name;
            if (color !== undefined) updates.color = color;
            if (icon !== undefined) updates.icon = icon;

            if (Object.keys(updates).length === 0) {
                return res.status(400).json({
                    error: 'No hay campos para actualizar',
                });
            }

            const category = await categoryModel.update(id, updates, req.user._id);

            if (!category) {
                return res.status(404).json({
                    error: "Categoría no encontrada"
                });
            }

            res.status(200).json({
                category: category
            });

        } catch (error) {
            res.status(500).json({
                error: "Error al actualizar categoría"
            });
        }
    }

    // ELIMINAR CATEGORÍA
    async delete(req, res) {
        try {
            const { id } = req.params;

            // Verificar si la categoría existe y pertenece al usuario
            const category = await categoryModel.getOneById(id, req.user._id);
            if (!category) {
                return res.status(404).json({
                    error: "Categoría no encontrada"
                });
            }

            // Verificar si tiene tareas asociadas
            const tasks = await taskModel.getAll({ categoryId: id, userId: req.user._id });
            if (tasks.length > 0) {
                return res.status(400).json({
                    error: "No se puede eliminar la categoría porque tiene tareas asociadas"
                });
            }

            // Eliminar la categoría
            await categoryModel.delete(id, req.user._id);

            res.status(200).json({
                message: "Categoría eliminada"
            });

        } catch (error) {
            res.status(500).json({
                error: "Error al eliminar categoría"
            });
        }
    }
}

export default new categoryControllers();