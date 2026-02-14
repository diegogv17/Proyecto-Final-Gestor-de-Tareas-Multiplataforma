import  dbclient from "../config/dbClient.js"

class userModel {
    async create(Usuario){
        const colUser = dbclient.db.collection('Usuario')
        await colUser.insertOne(Usuario)
    }
}

export default new userModel;