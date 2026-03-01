const { GoogleGenAI } = require("@google/genai");
const fs = require("fs");
require("dotenv").config();


const ai = new GoogleGenAI({
  apiKey: process.env.GOOGLE_CLOUD_API_KEY,
});

const model = "gemini-3.1-flash-image-preview";

const meals = JSON.parse(fs.readFileSync("./meals.json", "utf8"));

const outputDir = "./images";
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir);
}

async function generateImage(meal) {
  const prompt = `
Professional food photography of ${meal.name}.

The dish must be served inside a single clean ceramic bowl.
Only one bowl in the frame.
No extra plates.
No cutlery.
Top-down centered composition.
Natural daylight.
Minimal neutral background.
High detail.
Indian home-style meal.
No text.
No watermark.
Square image.
`;

  try {
    console.log(`Generating image for: ${meal.name}`);

    const response = await ai.models.generateContent({
      model,
      contents: [
        {
          role: "user",
          parts: [{ text: prompt }],
        },
      ],
      config: {
        responseModalities: ["IMAGE"],
        imageConfig: {
          aspectRatio: "1:1",
          imageSize: "1024x1024"
        }
      },
    });

    const imagePart =
      response.candidates[0].content.parts.find(
        (p) => p.inlineData
      );

    if (!imagePart) {
      console.log("No image returned.");
      return;
    }

    const imageBuffer = Buffer.from(
      imagePart.inlineData.data,
      "base64"
    );

    const fileName = `${meal.id}.png`;

    fs.writeFileSync(`${outputDir}/${fileName}`, imageBuffer);

    console.log(`Saved: ${fileName}`);
  } catch (error) {
    console.error(`Error generating ${meal.name}`, error.message);
  }
}

async function run() {
  for (const meal of meals) {
    await generateImage(meal);
    await new Promise((resolve) => setTimeout(resolve, 2000));
  }
  console.log("All images generated.");
}

run();