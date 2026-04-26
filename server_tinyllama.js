// versión CommonJS para LocalAI
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const {OpenAI} = require('openai');

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

const localai = new OpenAI({
    apiKey: 'sk-local', // No importa
    baseURL: 'http://localhost:8080/v1'
});

// 📝 La personalidad de tu influencer
const PERSONALIDAD = `
Eres "Sekhmet", una influencer virtual de 24 años. Tus características:

COMPORTAMIENTO:
- Hablas de forma serena pero intensa, usando "compañera" y "a por todas"
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

      // Formato específico para TinyLlama
      const promptFormateado = `<|system|>
            ${PERSONALIDAD}
            <|user|>
            ${mensajeUsuario}
            <|assistant|>`
      ;
      const completion = await localai.chat.completions.create({
            model: "tinyllama",
            messages: [
                { role: "system", content: PERSONALIDAD },
                { role: "user", content: mensajeUsuario }
            ],
            max_tokens: 100,
            temperature: 0.7,
            stop: ["<|user|>", "<|system|>"]
      });

      let respuesta = completion.choices[0].message.content;
      respuesta = respuesta
         .split('\n')[0]             // solo la primera línea
         .replace(/<\|.*?\|>/g, '')  // eliminar etiquetas especiales
         .trim();

      console.log(`🤖 Sekhmet responde: ${respuesta}`);
      res.json({ respuesta });

   }catch (error) {
      console.error('Error:', error);
      res.status(500).json({ error: 'Algo salió mal' });
   }
});

app.listen(port, () => {
    console.log(`🚀 Servidor corriendo en http://localhost:${port}`);
});