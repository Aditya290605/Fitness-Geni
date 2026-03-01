import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import dotenv from 'dotenv';

dotenv.config();

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const jsonFile = './uploaded-images.json';

async function updateDatabase() {
  if (!fs.existsSync(jsonFile)) {
    console.error("❌ uploaded-images.json not found");
    return;
  }

  const data = JSON.parse(fs.readFileSync(jsonFile, 'utf-8'));

  for (const item of data) {
    const mealId = item.name;          // UUID
    const imageUrl = item.image_url;

    console.log(`Updating ID: ${mealId}`);

    const { error } = await supabase
      .from('meals_catalog')
      .update({ image_url: imageUrl })
      .eq('id', mealId);

    if (error) {
      console.error(`❌ Failed updating ${mealId}:`, error.message);
      continue;
    }

    console.log(`✅ Updated ${mealId}`);
  }

  console.log("\n🎉 All updates complete.");
}

updateDatabase();