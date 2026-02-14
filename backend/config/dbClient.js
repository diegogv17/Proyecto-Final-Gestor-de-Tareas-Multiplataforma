import 'dotenv/config'
import { MongoClient } from "mongodb";

class dbclient{
    constructor(){
        const queryString = `mongodb+srv://${process.env.USER_DB}:${process.env.PASS_DB}@${process.env.SERVER_DB}/?appName=TCUFORUSPG`;
        this.client = new MongoClient(queryString)
        this.conectarBD();
    }

    async conectarBD(){
        try{
          await this.client.connect();
          this.db = this.client.db('Usuario')
          console.log("Se conecto correctamente a la base de datos")
        }
        catch(e){
            console.log(e)
        }
    }
}

export default new dbclient;
