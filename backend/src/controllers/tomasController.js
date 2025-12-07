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

export const registrarToma = async (req, res) => {
    const { medicamento_id, fecha_hora, estado, fecha_programada } = req.body;
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        
        // Use provided fecha_programada or default to fecha_hora (immediate take)
        const scheduledTime = fecha_programada || fecha_hora;
        const status = estado || 'TOMADO';

        const tomaRes = await client.query(
            'INSERT INTO toma (medicamento_id, fecha_programada, tomada, estado, fecha_real) VALUES ($1, $2, $3, $4, $5) RETURNING id;',
            [medicamento_id, scheduledTime, status === 'TOMADO', status, fecha_hora]
        );
        const tomaId = tomaRes.rows[0].id;

        // Keep filling historial for backward compatibility if needed, but toma table now has the data
        await client.query(
            'INSERT INTO historial (toma_id, fecha_real, cumplimiento) VALUES ($1, $2, $3);',
            [tomaId, fecha_hora, status === 'TOMADO']
        );

        await client.query('COMMIT');
        res.status(201).json({ message: 'Toma registrada exitosamente', tomaId });
    } catch (err) {
        await client.query('ROLLBACK');
        console.error('Error al registrar toma:', err);
        res.status(500).json({ error: 'Error al registrar toma' });
    } finally {
        client.release();
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

export const getTomasByUsuario = async (req, res) => {
    const { usuario_id } = req.params;
    const { fecha } = req.query; // Optional date filter YYYY-MM-DD

    try {
        let query = `
            SELECT t.* 
            FROM toma t
            INNER JOIN medicamento m ON t.medicamento_id = m.id
            WHERE m.usuario_id = $1
        `;
        const params = [usuario_id];

        if (fecha) {
            query += ` AND DATE(t.fecha_programada) = $2`;
            params.push(fecha);
        }
        
        query += ` ORDER BY t.fecha_programada DESC`;

        const result = await pool.query(query, params);
        res.json(result.rows);
    } catch (err) {
        console.error('Error al obtener tomas del usuario:', err);
        res.status(500).json({ error: 'Error al obtener tomas del usuario' });
    }
};
