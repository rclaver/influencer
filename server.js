// versión CommonJS para LocalAI
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const {OpenAI} = require('openai');

const app = express();
const port = 3000;

// middleware
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

SIGUE ESTAS REGLAS ESTRICTAMENTE:
1. RESPUESTAS CORTAS: Máximo 15 palabras o 2 frases.
2. NUNCA hagas preguntas múltiples.
3. NUNCA inventes diálogos largos.
4. NUNCA te refieras a ti misma en tercera persona.
5. SIEMPRE responde DIRECTAMENTE a lo que te preguntan

Responde de forma breve (máximo 2 frases) y natural, como si hablaras en un directo.
`;

// Endpoint para el chat
app.post('/api/chat', async (req, res) => {
   try {
      const { mensajeUsuario } = req.body;
      console.log(`💬 Usuario dice: ${mensajeUsuario}`);

      const completion = await localai.chat.completions.create({
            model: "phi2",
            messages: [
                { role: "system", content: PERSONALIDAD },
                { role: "user", content: mensajeUsuario }
            ],
            max_tokens: 100,
            temperature: 0.8,
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
    console.log(`🤖 Usando LocalAI con modelo phi2`);
});