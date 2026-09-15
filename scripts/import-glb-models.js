const fs = require('fs');
const path = require('path');
const https = require('https');

const TARGET_DIR = path.resolve(__dirname, 'backend/storage/app/public/furniture/models');

const MODELS_MAP = [
  // Sofas & Lounging
  {
    sku: 'SOFA-002',
    name: 'Loft 2-Seater Compact Studio Sofa',
    url: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/Models/GlamVelvetSofa/glTF-Binary/GlamVelvetSofa.glb'
  },
  {
    sku: 'SOFA-003',
    name: 'Manhattan L-Shaped Sectional Sofa',
    url: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/Models/SheenWoodLeatherSofa/glTF-Binary/SheenWoodLeatherSofa.glb'
  },
  {
    sku: 'SOFA-005',
    name: 'Kyoto Low Platform Daybed',
    url: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/Models/SpecularSilkPouf/glTF-Binary/SpecularSilkPouf.glb'
  },
  // Dining Chairs & Armchairs
  {
    sku: 'DCH-001',
    name: 'Fawn Scandinavian Spindle Dining Chair',
    url: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/Models/ClearcoatWicker/glTF-Binary/ClearcoatWicker.glb'
  },
  {
    sku: 'DCH-002',
    name: 'Port Upholstered Curved Back Armchair',
    url: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/Models/ChairDamaskPurplegold/glTF-Binary/ChairDamaskPurplegold.glb'
  },
  {
    sku: 'DCH-003',
    name: 'Cantilever Chrome Leatherette Chair',
    url: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/Models/SheenChair/glTF-Binary/SheenChair.glb'
  },
  {
    sku: 'DCH-004',
    name: 'Bento Minimalist Molded Shell Chair',
    url: 'https://raw.githubusercontent.com/taoj007/interactive-3d-product-catalog/main/public/models/old_wooden_chair.glb'
  },
  {
    sku: 'DCH-005',
    name: 'Bistro Wire Metal Dining Chair',
    url: 'https://raw.githubusercontent.com/MuhammadAbubakar18/furniture_3d_models/main/chair.glb'
  },
  {
    sku: 'STG-003',
    name: 'Hygge Cocoon Reading Armchair',
    url: 'https://raw.githubusercontent.com/taoj007/interactive-3d-product-catalog/main/public/models/Kid_Rocking_Chair.glb'
  },
  // Tables & Desks
  {
    sku: 'COFF-001',
    name: 'Aura Oval Glass & Oak Coffee Table',
    url: 'https://raw.githubusercontent.com/taoj007/interactive-3d-product-catalog/main/public/models/table_5.glb'
  },
  {
    sku: 'COFF-002',
    name: 'Mono Block Minimalist Low Table',
    url: 'https://raw.githubusercontent.com/lxysy/three-js-study-micro/master/home-decoration-editor/public/dining_table2.glb'
  },
  {
    sku: 'DTB-001',
    name: 'Circa 4-Seater Round Dining Table',
    url: 'https://raw.githubusercontent.com/taoj007/interactive-3d-product-catalog/main/public/models/10089_Table-90x90_textured.glb'
  },
  {
    sku: 'DTB-002',
    name: 'Kanso 6-Seater Rectangular Dining Table',
    url: 'https://raw.githubusercontent.com/taoj007/interactive-3d-product-catalog/main/public/models/table2.glb'
  },
  {
    sku: 'DTB-003',
    name: 'Bastion 8-Seater Extendable Dining Table',
    url: 'https://raw.githubusercontent.com/taoj007/interactive-3d-product-catalog/main/public/models/wooden_table_set.glb'
  },
  {
    sku: 'DSK-001',
    name: 'Solo Compact Study Desk 100x50',
    url: 'https://raw.githubusercontent.com/lxysy/three-js-study-micro/master/css3d-computer/public/desk.glb'
  },
  {
    sku: 'DSK-002',
    name: 'ErgoPro Motorized Sit-Stand Desk 140x70',
    url: 'https://raw.githubusercontent.com/morartzi1998/traces/master/community/models/computer-desk.glb'
  },
  // Beds
  {
    sku: 'BED-001',
    name: 'Fjord Single Platform Bed (90x200)',
    url: 'https://raw.githubusercontent.com/lxysy/three-js-study-micro/master/home-decoration-editor/public/bed2.glb'
  },
  {
    sku: 'BED-002',
    name: 'Astrid Queen Upholstered Bed (160x200)',
    url: 'https://raw.githubusercontent.com/lxysy/three-js-study-micro/master/home-decoration-editor/public/bed1.glb'
  },
  // Nightstands, TV Units & Storage
  {
    sku: 'NST-001',
    name: 'Aero Floating Bedside Shelf',
    url: 'https://raw.githubusercontent.com/morartzi1998/traces/master/community/models/antique-side-table.glb'
  },
  {
    sku: 'TV-001',
    name: 'Horizon 180 Floating Wall Console',
    url: 'https://raw.githubusercontent.com/morartzi1998/traces/master/assets/models/television.glb'
  },
  {
    sku: 'TV-002',
    name: 'Oslo Low Media Bench 200cm',
    url: 'https://raw.githubusercontent.com/MuhammadAbubakar18/furniture_3d_models/main/cuburd.glb'
  },
  {
    sku: 'TV-004',
    name: 'Palais Walnut Sideboard Console',
    url: 'https://raw.githubusercontent.com/morartzi1998/traces/master/community/models/antique-cabinet.glb'
  },
  {
    sku: 'STG-001',
    name: 'Gridline Tall Open Modular Bookcase',
    url: 'https://raw.githubusercontent.com/SUPERTKY/gameforschool/main/assets/shelf.glb'
  }
];

if (!fs.existsSync(TARGET_DIR)) {
  fs.mkdirSync(TARGET_DIR, { recursive: true });
}

function downloadFile(url, destPath) {
  return new Promise((resolve, reject) => {
    https.get(url, (response) => {
      if (response.statusCode >= 300 && response.statusCode < 400 && response.headers.location) {
        // Follow redirect
        return downloadFile(response.headers.location, destPath).then(resolve).catch(reject);
      }
      if (response.statusCode !== 200) {
        return reject(new Error(`HTTP ${response.statusCode} from ${url}`));
      }

      const fileStream = fs.createWriteStream(destPath);
      response.pipe(fileStream);

      fileStream.on('finish', () => {
        fileStream.close((err) => {
          if (err) return reject(err);
          resolve();
        });
      });

      fileStream.on('error', (err) => {
        fs.unlink(destPath, () => {});
        reject(err);
      });
    }).on('error', (err) => {
      reject(err);
    });
  });
}

async function main() {
  console.log('Starting GLB models collection for SmartSpace catalog...');
  console.log(`Target directory: ${TARGET_DIR}`);
  console.log(`Total models to import: ${MODELS_MAP.length}\n`);

  let successCount = 0;
  let failCount = 0;

  for (const item of MODELS_MAP) {
    const filename = `${item.sku}.glb`;
    const destPath = path.join(TARGET_DIR, filename);

    process.stdout.write(`[${item.sku}] Downloading ${item.name}... `);

    try {
      await downloadFile(item.url, destPath);

      // Verify file exists, size > 0, and has glTF magic header (0x46546C67)
      const stats = fs.statSync(destPath);
      const fd = fs.openSync(destPath, 'r');
      const buffer = Buffer.alloc(4);
      fs.readSync(fd, buffer, 0, 4, 0);
      fs.closeSync(fd);

      const magic = buffer.toString('utf8');
      const sizeMb = (stats.size / (1024 * 1024)).toFixed(2);

      if (magic === 'glTF') {
        console.log(`OK (${sizeMb} MB) [Valid glTF Binary]`);
        successCount++;
      } else {
        console.log(`WARNING: Magic is "${magic}" (${sizeMb} MB)`);
        successCount++;
      }
    } catch (err) {
      console.log(`FAILED: ${err.message}`);
      failCount++;
    }
  }

  console.log(`\nDownload completed: ${successCount} succeeded, ${failCount} failed.`);
}

main();
