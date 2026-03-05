// Importa las variables de entorno desde el archivo .env
// Permite usar process.env.JWT_TOKEN_SECRET
import 'dotenv/config';

// Importa la librería jsonwebtoken para generar y verificar tokens JWT
import jsonwebtoken from 'jsonwebtoken';

// Función que genera un token JWT
// Recibe como parámetro el email del usuario autenticado
export function generarToken(email) {
        // sign() crea un token firmado digitalmente
    // Primer parámetro: payload (datos que guardamos dentro del token)
    // Segundo parámetro: clave secreta para firmar el token
    // Tercer parámetro: opciones, en este caso expira en 1 hora
    return jsonwebtoken.sign({ email }, process.env.JWT_TOKEN_SECRET, { expiresIn: '1h' });
}

// Middleware para verificar si el token enviado por el cliente es válido
// Se usa para proteger rutas privadas
export function verificarToken(req, res, next) {

    // Obtiene el header Authorization
    // El formato esperado es: "Bearer TOKEN_AQUI"
    // Se usa replace para eliminar la palabra "Bearer " y quedarse solo con el token
    const token = req.header('Authorization')?.replace('Bearer ', '');
    // Si no existe token, se bloquea el acceso
    if (!token) {
        return res.status(401).json({ error: 'Token requerido' });
    }

    try {
        // Verifica que el token sea válido usando la misma clave secreta
        // Si el token fue alterado o expiró, lanzará un error
        const dataToken = jsonwebtoken.verify(token, process.env.JWT_TOKEN_SECRET);
        // Extrae el email del payload del token
        // y lo guarda en el objeto request
        // Esto permite usar req.emailConectado en las rutas protegidas
        req.emailConectado = dataToken.email;
        // Continúa hacia el siguiente middleware o controlador
        next();
    } catch (e) {

        // Si ocurre un error (token inválido o expirado)
        // se devuelve error 401 Unauthorized
        return res.status(401).json({ error: 'Token no válido' });
    }

}

