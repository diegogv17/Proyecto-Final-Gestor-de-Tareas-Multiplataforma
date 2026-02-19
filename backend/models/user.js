// Importamos el modelo de usuario que contiene las operaciones con la base de datos
import mongoose from 'mongoose'
// Importamos el schema de usuario que contiene los datos especificos que iran a DB
import user from '../schemas/user.js'

class userModel {
    async create(usercollections){
        return await user.create(usercollections)
    }
    //modelo para obtener todo los datos (GET)
    async getAll(){
        return await user.find()
    }
    //modelo para actualizar datos (PUT)
    async update(_id,data){
         return await user.findOneAndUpdate({ _id: new mongoose.Types.ObjectId(_id) },   // ← ESTO ES LO IMPORTANTE
        {
            ...data,
            updatedAt: new Date()
        },
        { new: true }
    )
    }

    //modelo para obtener los datos especificos (GET\id)
    async getOne(id) {
        return await user.findOne({ _id: new mongoose.Types.ObjectId(id) })
    }

    //modelo para eliminar los datos especificos(DELETE)
    async delete(id){
       return await user.findOneAndDelete({ _id: new mongoose.Types.ObjectId(id) }, {new: true})
    }
}

//Se exporta 
export default new userModel;