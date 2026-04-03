// Importa las variables de entorno desde el archivo .env
import 'dotenv/config'

// Importa mongoose, que es la librería para conectarse a MongoDB
import mongoose from 'mongoose';

// Importa el módulo DNS para configurar servidores DNS manualmente https://www.mongodb.com/community/forums/t/error-querysrv-econnrefused-mongodb/259042
import dns from "node:dns/promises";


// Establece servidores DNS públicos para evitar errores como:
// querySrv ECONNREFUSED o ENOTFOUND en MongoDB Atlas https://www.mongodb.com/community/forums/t/error-querysrv-econnrefused-mongodb/259042
dns.setServers(["1.1.1.1", "8.8.8.8"]);

// Clase que maneja la conexión a la base de datos
class dbclient{
    constructor(){
        this.conectarBaseDatos()
    }

    // MÉTODO PARA CONECTAR A MONGODB
    async conectarBaseDatos(){
         try{

        // Obtiene la URI de conexión desde el archivo .env
        const queryString = process.env.MONGODB_URI;

        // Conecta mongoose a MongoDB Atlas o MongoDB local
        await mongoose.connect(queryString)
        
        // Mensaje de éxito en consola
        console.log("Conectado a MongoDB");
         }
        catch(e){

            // Si ocurre un error, lo muestra en consola
            console.error("❌ Error al conectar:", e);
        }
    
    }

    // MÉTODO PARA CERRAR LA CONEXIÓN
    async cerrarConexion(){
        try{
            // Cierra la conexión con MongoDB
            await mongoose.disconnect()
            console.log("Conexion a la base de Datos fue cerrada")
        }catch(e){
            console.error("Error al cerrar la base de Datos:",e)
        }
    }
    
}


// Exporta una instancia única (Singleton)
// Esto asegura que solo haya una conexión a la base de datos
export default new dbclient();
