import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';

dotenv.config();

// === CONFIG ===
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const bucketName = process.env.BUCKET_NAME;
const imagesFolder = './images'; // folder where images are stored
const outputJson = './uploaded-images.json';

// === HELPERS ===
function slugify(name) {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '');
}

// === MAIN ===
async function uploadImages() {
  const files = fs.readdirSync(imagesFolder);

  const results = [];

  for (const file of files) {
    const filePath = path.join(imagesFolder, file);

    // Skip non-files
    if (!fs.statSync(filePath).isFile()) continue;

    const fileExt = path.extname(file);
    const fileNameWithoutExt = path.basename(file, fileExt);
    const slug = slugify(fileNameWithoutExt);

    const storagePath = `${slug}${fileExt}`;

    console.log(`Uploading: ${fileNameWithoutExt}`);

    const fileBuffer = fs.readFileSync(filePath);

    const { data, error } = await supabase.storage
      .from(bucketName)
      .upload(storagePath, fileBuffer, {
        contentType: `image/${fileExt.replace('.', '')}`,
        upsert: true,
      });

    if (error) {
      console.error(`❌ Failed: ${fileNameWithoutExt}`, error.message);
      continue;
    }

    // Get Public URL
    const { data: publicUrlData } = supabase.storage
      .from(bucketName)
      .getPublicUrl(storagePath);

    const publicUrl = publicUrlData.publicUrl;

    results.push({
      name: fileNameWithoutExt,
      image_url: publicUrl,
    });

    console.log(`✅ Uploaded: ${publicUrl}`);
  }

  // Save JSON
  fs.writeFileSync(outputJson, JSON.stringify(results, null, 2));

  console.log('\n🎉 Upload Complete!');
  console.log(`📄 JSON saved at: ${outputJson}`);
}

uploadImages();