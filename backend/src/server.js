import express from 'express';
import usuariosRoutes from './routes/usuarios.js';
import medicamentosRoutes from './routes/medicamentos.js';
import tomasRoutes from './routes/tomas.js';
import historialRoutes from './routes/historial.js';

const app = express();
const PORT = process.env.APP_PORT || 3000;

app.use(express.json());

app.use('/usuarios', usuariosRoutes);
app.use('/medicamentos', medicamentosRoutes);
app.use('/tomas', tomasRoutes);
app.use('/historial', historialRoutes);

app.get('/', (req, res) => {
    res.send('API MedTrack funcionando 🚀');
});

app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});