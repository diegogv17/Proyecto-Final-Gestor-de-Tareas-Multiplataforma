import 'dotenv/config'
import express from 'express'
//import route from './routes/userRoutes.js';
//import dbClient from './config/dbClient.js';

const app = express();



app.use('/user', route)

try{
    const PORT = process.env.PORT || 300;
    app.listen(PORT, () => console.log('servidor Activo en el puerto ' + PORT))
}
catch(e){
 console.log(e)
}
