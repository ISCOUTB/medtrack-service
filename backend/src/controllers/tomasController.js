import { pool } from '../db/pool.js';

export const getTomas = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM toma;');
        res.json(result.rows);
    } catch (err) {
        console.error('Error en consulta tomas:', err);
        res.status(500).json({ error: 'Error al obtener tomas' });
    }
};

export const createToma = async (req, res) => {
    const { medicamento_id, fecha_hora, realizada } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO toma (medicamento_id, fecha_hora, realizada) VALUES ($1, $2, $3) RETURNING *;',
            [medicamento_id, fecha_hora, realizada]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error al crear toma:', err);
        res.status(500).json({ error: 'Error al crear toma' });
    }
};

export const updateToma = async (req, res) => {
    const { id } = req.params;
    const { fecha_hora, realizada } = req.body;
    try {
        const result = await pool.query(
            'UPDATE toma SET fecha_hora = $1, realizada = $2 WHERE id = $3 RETURNING *;',
            [fecha_hora, realizada, id]
        );
        res.json(result.rows[0]);
    } catch (err) {
        console.error('Error al actualizar toma:', err);
        res.status(500).json({ error: 'Error al actualizar toma' });
    }
};

export const deleteToma = async (req, res) => {
    const { id } = req.params;
    try {
        await pool.query('DELETE FROM toma WHERE id = $1;', [id]);
        res.status(204).send();
    } catch (err) {
        console.error('Error al eliminar toma:', err);
        res.status(500).json({ error: 'Error al eliminar toma' });
    }
};
