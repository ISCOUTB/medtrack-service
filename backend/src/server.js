import express from 'express';
import usuariosRoutes from './routes/usuarios.js';
import medicamentosRoutes from './routes/medicamentos.js';
import tomasRoutes from './routes/tomas.js';
import historialRoutes from './routes/historial.js';
import swaggerUi from 'swagger-ui-express';
import swaggerJsdoc from 'swagger-jsdoc';

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

const swaggerOptions = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'MedTrack API',
            version: '1.0.0',
            description: 'Documentación de la API MedTrack con Swagger/OpenAPI',
        },
        servers: [
            {
                url: 'http://localhost:3000',
            },
        ],
    },
    apis: ['./src/routes/*.js'],
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});