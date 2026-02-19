import 'dotenv/config'
import { MongoClient } from "mongodb";
import dns from "node:dns/promises";

dns.setServers(["1.1.1.1", "8.8.8.8"]);


class dbclient{
    constructor(){
        const queryString = process.env.MONGODB_URI;
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

export default new dbclient();
