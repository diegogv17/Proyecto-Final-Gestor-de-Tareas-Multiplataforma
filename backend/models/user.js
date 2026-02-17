import  dbclient from "../config/dbClient.js"

class userModel {
    async create(userCollection){
        const colUser = dbclient.db.collection('userCollection')
        await colUser.insertOne(userCollection)
    }
}

export default new userModel;