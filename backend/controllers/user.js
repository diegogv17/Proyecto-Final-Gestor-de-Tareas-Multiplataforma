// Importamos el modelo de usuario que contiene las operaciones con la base de datos
import userModel from '../models/user.js'

// Clase que contiene todos los controladores (controllers) para manejar las peticiones HTTP
class userControllers {
    constructor(){
        // El constructor está vacío porque no necesitamos inicializar nada por ahora

    }
    async create(req,res){
        try
        {
         // req.body contiene los datos enviados desde el cliente (Postman o frontend)
        const data = await userModel.create(req.body);

         // Respondemos con status 201 (Created) y el usuario creado
         res.status(201).json(data);
        }
        catch(e)
        {
            // Si ocurre un error, enviamos status 500 (error del servidor)
            res.status(500).send(e)
        }
    }


    // ACTUALIZAR USUARIO (PUT)
    async update(req,res){
        try
        {
        // Obtenemos el id desde los parámetros de la URL
         const {id} = req.params
         // Llamamos al modelo para actualizar el usuario con ese id
         const data = await userModel.update(id, req.body);
         // Respondemos con status 200 (OK) y el usuario actualizado
         res.status(200).json(data);
        }
        catch(e)
        {   
            // Mostramos el error en consola para depuración
            console.log(e)

            // Enviamos error 500 al cliente
            res.status(500).send(e)
        }
    }
    // ELIMINAR USUARIO (DELETE)
    async delete(req,res){
        try
        {
        // Obtenemos el id desde la URL
         const {id} = req.params

         // Llamamos al modelo para eliminar el usuario
         const data = await userModel.delete(id);

         // Respondemos con el usuario eliminado
         res.status(206).json(data);
        }
        catch(e)
        {
            res.status(500).send(e)
        }
    }

     // OBTENER UN USUARIO (GET ONE)
    async getOne(req,res){
        try
        {            
         // Obtenemos el id desde la URL
         const {id} = req.params

         // Buscamos el usuario en la base de datos
         const data = await userModel.getOne(id);

         // Respondemos con el usuario encontrado
         res.status(201).json(data);
        }
        catch(e)
        {
            res.status(500).send(e)
        }
    }

     // OBTENER TODOS LOS USUARIOS (GET)
    async getAll(req,res){
        try
        {
            // Obtenemos todos los usuarios desde el modelo
        const data = await userModel.getAll();
        // Respondemos con la lista de usuarios
         res.status(201).json(data);
        }
        catch(e)
        {
            res.status(500).send(e)
        }
    }

    
}
// Exportamos 
export default new userControllers();