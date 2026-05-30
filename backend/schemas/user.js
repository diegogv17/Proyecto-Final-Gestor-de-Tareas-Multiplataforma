// ============================================================
// Schema de Usuario (Mongoose)
// ============================================================
// Define la estructura que tendrán los documentos de usuario
// en la colección de MongoDB. Cada campo tiene tipo, validaciones
// y opciones como unique, required, etc.
// ============================================================
import mongoose from "mongoose";

const userSchema = new mongoose.Schema({

    // Email único (no pueden haber dos usuarios con el mismo email)
    email: {
        type: String,
        required: true,   // Campo obligatorio
        unique: true,     // Valor único en la colección
        lowercase: true,  // Se guarda en minúsculas automáticamente
        trim: true        // Elimina espacios al inicio y final
    },

    // Contraseña (se almacena ENCRIPTADA con bcrypt, nunca en texto plano)
    password: {
        type: String,
        required: true
    },

    // Nombre completo del usuario
    name: {
        type: String,
        required: true,
        trim: true
    },

    // Fecha de creación del registro
    createdAt: {
        type: Date,
        default: Date.now
    },

    // Fecha de última actualización
    updatedAt: {
        type: Date,
        default: Date.now
    }

},
{
    versionKey: false // Elimina el campo __v que agrega Mongoose por defecto
})

// Exporta el modelo para poder usarlo en los controladores
export default mongoose.model('User', userSchema);
