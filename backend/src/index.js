import express from 'express';
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

const app = express();
app.use(express.json());

app.get('/health', async (_req, res) => {
    try {
        const result = await pool.query('SELECT NOW() AS now');
        res.json({ status: 'ok', now: result.rows[0].now });
    } catch (err) {
        res.status(500).json({ status: 'error', error: err.message });
    }
});

app.listen(process.env.APP_PORT || 3000, () =>
    console.log(`API corriendo en puerto ${process.env.APP_PORT || 3000}`)
);
