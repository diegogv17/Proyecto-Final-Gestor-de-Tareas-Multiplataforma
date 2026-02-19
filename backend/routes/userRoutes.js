// Importamos express para poder crear las rutas
import express from 'express'
// Creamos un Router de express para manejar las rutas de usuario
const route = express.Router();
// Importamos el controlador de usuario
import user from '../controllers/user.js'


// POST /user
// Crear un nuevo usuario
route.post('/', user.create)


// GET /user/:id
// Obtener un usuario específico por su ID
// Ejemplo: /user/6996b54850c22a128bf6e699
route.get('/:id', user.getOne)


// GET /user
// Obtener todos los usuarios
route.get('/', user.getAll)



// PUT /user/:id
// Actualizar un usuario por su ID
route.put('/:id',user.update)



// DELETE /user/:id
// Eliminar un usuario por su ID
route.delete('/:id',user.delete)


//Se exporta
export default route;