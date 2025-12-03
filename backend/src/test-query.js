import pkg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const { Pool } = pkg;

const pool = new Pool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
});

(async () => {
    try {
        const res = await pool.query('SELECT * FROM usuario;');
        console.log('Usuarios:', res.rows);
    } catch (err) {
        console.error('Error en consulta:', err);
    } finally {
        await pool.end();
    }
})();
