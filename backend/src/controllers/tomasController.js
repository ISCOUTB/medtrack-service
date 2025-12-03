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
    const { medicamento_id, fecha_programada } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO toma (medicamento_id, fecha_programada) VALUES ($1, $2) RETURNING *;',
            [medicamento_id, fecha_programada]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error al crear toma:', err);
        res.status(500).json({ error: 'Error al crear toma' });
    }
};

export const updateToma = async (req, res) => {
    const { id } = req.params;
    const { fecha_programada } = req.body;
    try {
        const result = await pool.query(
            'UPDATE toma SET fecha_programada = $1 WHERE id = $2 RETURNING *;',
            [fecha_programada, id]
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

export const getTomaHistorial = async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query(
            `SELECT h.id, h.observacion, h.toma_id
       FROM historial h
       INNER JOIN toma t ON h.toma_id = t.id
       WHERE t.id = $1;`,
            [id]
        );
        res.json(result.rows);
    } catch (err) {
        console.error('Error al obtener historial de la toma:', err);
        res.status(500).json({ error: 'Error al obtener historial de la toma' });
    }
};
