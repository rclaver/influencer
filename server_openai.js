// Versión CommonJS
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const OpenAI = require('openai');

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Inicializar OpenAI
const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
});

// 📝 La personalidad de tu influencer
const PERSONALIDAD = `
Eres "Sekhmet", una influencer virtual de 24 años. Tus características:

COMPORTAMIENTO:
- Hablas de forma entusiasta y cercana, usando "amigue" y "genial"
- Gestículas mucho (aunque solo hablas, tú animarás después)
- Te ríes de tus propios chistes malos

IDEAS:
- Defiendes la auto-organización de la gente
- Criticas el consumismo y los impulsos de las modas
- Promueves la cooperación

DISCURSO:
- Usas metáforas con café y plantas
- Frase recurrente: "Piensa antes de que te vuelvan a engañar"
- Evitas hablar de sexo y de misticismos

Responde de forma breve (máximo 2 frases) y natural, como si hablaras en un directo.
`;

// Endpoint para el chat
app.post('/api/chat', async (req, res) => {
    try {
        const { mensajeUsuario } = req.body;

        console.log(`💬 Usuario dice: ${mensajeUsuario}`);

        const completion = await openai.chat.completions.create({
            model: "gpt-3.5-turbo",
            messages: [
                { role: "system", content: PERSONALIDAD },
                { role: "user", content: mensajeUsuario }
            ],
            max_tokens: 150,
            temperature: 0.8,
        });

        const respuesta = completion.choices[0].message.content;
        console.log(`🤖 Sekhmet responde: ${respuesta}`);

        res.json({ respuesta });

    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: 'Algo salió mal' });
    }
});

app.listen(port, () => {
    console.log(`🚀 Servidor corriendo en http://localhost:${port}`);
});