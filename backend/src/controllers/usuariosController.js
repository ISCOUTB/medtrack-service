import { pool } from '../db/pool.js';

export const getUsuarios = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM usuario;');
        res.json(result.rows);
    } catch (err) {
        console.error('Error en consulta usuarios:', err);
        res.status(500).json({ error: 'Error al obtener usuarios' });
    }
};

export const createUsuario = async (req, res) => {
    const { nombre, email, password_hash } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO usuario (nombre, email, password_hash) VALUES ($1, $2, $3) RETURNING *;',
            [nombre, email, password_hash]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error al crear usuario:', err);
        res.status(500).json({ error: 'Error al crear usuario' });
    }
};
