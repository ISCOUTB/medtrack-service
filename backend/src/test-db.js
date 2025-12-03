import dotenv from 'dotenv';
import pg from 'pg';

dotenv.config();
const { Pool } = pg;

const pool = new Pool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
});

(async () => {
    try {
        const res = await pool.query('SELECT NOW()');
        console.log('Conexión exitosa:', res.rows[0].now);
    } catch (err) {
        console.error('Error de conexión:', err.message);
    } finally {
        pool.end();
    }
})();
