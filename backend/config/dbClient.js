// ============================================================
// Cliente de Base de Datos (MongoDB + Mongoose)
// ============================================================
// Este archivo se ejecuta al iniciar el servidor y establece
// la conexión con MongoDB Atlas (o local).
// Usa el patrón Singleton para que solo exista UNA conexión
// a la base de datos en toda la aplicación.
// ============================================================
import 'dotenv/config'
import mongoose from 'mongoose';
import dns from "node:dns/promises";

// Configura servidores DNS públicos para evitar errores de
// resolución de nombres en MongoDB Atlas (querySrv ECONNREFUSED)
dns.setServers(["1.1.1.1", "8.8.8.8"]);

class dbclient{
    constructor(){
        // Al crear la instancia, conecta automáticamente
        this.conectarBaseDatos()
    }

    // ================================================================
    // CONECTAR A MONGODB
    // Lee la URI desde la variable de entorno MONGODB_URI (.env)
    // y establece la conexión usando Mongoose.
    // ================================================================
    async conectarBaseDatos(){
         try{
            const queryString = process.env.MONGODB_URI; // URI desde .env
            await mongoose.connect(queryString);            // Conecta a MongoDB
            console.log("Conectado a MongoDB");
         }
        catch(e){
            console.error("❌ Error al conectar:", e);
        }
    }

    // ================================================================
    // CERRAR CONEXIÓN
    // Se llama cuando el servidor se detiene (SIGINT)
    // para cerrar la conexión de forma ordenada.
    // ================================================================
    async cerrarConexion(){
        try{
            await mongoose.disconnect();
            console.log("Conexion a la base de Datos fue cerrada");
        }catch(e){
            console.error("Error al cerrar la base de Datos:",e);
        }
    }
}

// Exporta una instancia única (Singleton)
// Así toda la app usa la misma conexión a MongoDB
export default new dbclient();
