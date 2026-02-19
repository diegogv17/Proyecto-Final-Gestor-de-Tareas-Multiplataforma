// Importa las variables de entorno desde el archivo .env
import 'dotenv/config'

// Importa express para crear el servidor
import express from 'express'

// Importa las rutas de usuario
import route from './routes/userRoutes.js';

// Importa body-parser para poder leer JSON del cliente
import bodyParser from 'body-parser'

// Importa el cliente de base de datos (esto conecta automáticamente a MongoDB)
import dbClient from './config/dbClient.js';


// Crea la aplicación express
const app = express();


// MIDDLEWARES
// Permite al servidor leer JSON enviado en las peticiones
app.use(bodyParser.json())
// Permite leer datos enviados desde formularios
app.use(bodyParser.urlencoded({extended : true}))


// RUTAS
// Todas las rutas definidas en userRoutes.js tendrán el prefijo /api/auth
// Ejemplo: POST /api/auth/register, GET /api/auth/me, etc.
app.use('/api/auth', route)


// INICIAR SERVIDOR
try{

    // Obtiene el puerto desde .env o usa el 3000 por defecto
    const PORT = process.env.PORT || 3000;

    // Inicia el servidor
    app.listen(PORT, () => 
        console.log('Servidor activo en el puerto ' + PORT)
    )

}
catch(e){

    // Muestra error si el servidor no puede iniciar
    console.log(e)

}

// CERRAR CONEXIÓN A MONGODB AL TERMINAR
// Este evento se ejecuta cuando presionas CTRL + C en la terminal
process.on('SIGINT', async()=> {

    // Cierra la conexión con MongoDB
    await dbClient.cerrarConexion()

    console.log("Servidor detenido")

    process.exit(0)
})
