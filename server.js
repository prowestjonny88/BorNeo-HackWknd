// NEW VERSION (using @google/genai)
const { GoogleGenAI } = require("@google/genai"); 
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Initialize the new client
const ai = new GoogleGenAI({ apiKey: "YOUR_OWN_GEMINI_API" });

app.post('/evaluate', async (req, res) => {
    try {
        const { imageBase64, mimeType, latitude, longitude } = req.body;

        const weatherContext = await getWeatherWarning();

        // Using @google/genai API - call ai.models.generateContent() directly
        const result = await ai.models.generateContent({
            model: "gemini-flash-latest",
            contents: [
                { 
                  text: `User Location: Lat ${latitude}, Lng ${longitude}. 
                         Current MET Malaysia Warning: "${weatherContext}". 
                         Based on this location, the weather, and the attached image, is it safe for children to be outside? 
                         Respond only with Yes or No and a 1-sentence reason.` 
                },
                { inlineData: { data: imageBase64, mimeType: mimeType } }
            ]
        });

        const responseText = result.text; 
        
        console.log("AI Answer:", responseText);
        res.json({ result: responseText });

    } catch (error) {
        console.error("Gemini Error:", error);
        res.status(500).json({ error: "Analysis failed" });
    }
});

async function getWeatherWarning() {
    const url = "https://api.data.gov.my/weather/warning?limit=1";
    try {
        const response = await fetch(url);
        const data = await response.json();
        
        if (data && data.length > 0) {
            const latest = data[0];
            return `Current Warning: ${latest.title_en}. Details: ${latest.text_en}`;
        }
    } catch (e) {
        console.log("Weather API error", e);
    }
    return "No active warnings.";
}

app.listen(3000, () => console.log('Backend running on http://localhost:3000'));

/* RUN IN TERMINAL: node server.js*/