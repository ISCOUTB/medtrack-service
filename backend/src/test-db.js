import dotenv from "dotenv";
import pkg from "pg";

dotenv.config();
const { Pool } = pkg;

const pool = new Pool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
});

pool.connect()
    .then(client => {
        console.log("Conexión exitosa:", new Date().toISOString());
        client.release();
        pool.end();
    })
    .catch(err => {
        console.error("Error de conexión:", err.message);
        pool.end();
    });
