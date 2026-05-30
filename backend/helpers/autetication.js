// ============================================================
// Helpers de Autenticación (JWT)
// ============================================================
// generarToken:    Crea un token JWT firmado con la clave secreta
// verificarToken:  Middleware que protege rutas privadas
//
// JWT (JSON Web Token) es un estándar para tokens de acceso.
// Permite que el servidor verifique la identidad del usuario
// sin necesidad de mantener sesión en el servidor.
// ============================================================
import 'dotenv/config';
import jsonwebtoken from 'jsonwebtoken';
import userModel from '../models/user.js';

// ================================================================
// GENERAR TOKEN JWT
// Recibe: email del usuario
// Devuelve: token firmado con expiración de 7 días
// ================================================================
export function generarToken(email) {
    // Sign crea un token con:
    // - Payload: { email }  (datos dentro del token)
    // - Clave secreta: process.env.JWT_TOKEN_SECRET (desde .env)
    // - Opciones: expira en 7 días
    return jsonwebtoken.sign(
        { email },
        process.env.JWT_TOKEN_SECRET,
        { expiresIn: '7d' }
    );
}

// ================================================================
// VERIFICAR TOKEN (Middleware)
// Se ejecuta ANTES del controlador en rutas protegidas.
// Extrae el token del header Authorization, lo verifica y
// agrega los datos del usuario a req para el controlador.
// ================================================================
export async function verificarToken(req, res, next) {
    console.log('Verificando token...');

    // El token viene en el header: "Authorization: Bearer <TOKEN>"
    const token = req.header('Authorization')?.replace('Bearer ', '');
    console.log('Token recibido:', !!token);

    if (!token) {
        console.log('No token provided');
        return res.status(401).json({ error: 'Token requerido' });
    }

    try {
        // Verifica que el token sea válido (firma + expiración)
        const dataToken = jsonwebtoken.verify(
            token, process.env.JWT_TOKEN_SECRET
        );
        console.log('Token verificado:', dataToken);

        const email = dataToken.email;

        // Busca el usuario en la base de datos
        const user = await userModel.getOne({ email });
        console.log('Usuario encontrado:', !!user);

        if (!user) {
            return res.status(401).json({ error: 'Usuario no encontrado' });
        }

        // Guarda el usuario en req para que el controlador lo use
        req.user = user;                // Usuario completo
        req.emailConectado = email;     // Solo email (compatibilidad)

        console.log('Middleware completado, continuando...');
        next(); // Continúa al controlador

    } catch (e) {
        console.log('Error en token:', e.message);
        return res.status(401).json({ error: 'Token no válido' });
    }
}
