---
title: "08 — 3D Asset Pipeline & Operations"
tags:
  - smartspace
  - blender
  - glb
  - assets
  - 3d-pipeline
created: 2026-09-12
---

# 🎨 08 — 3D Asset Pipeline & Operations

Back to [[00 - Home|🏠 Documentation Hub]]

---

## 1. 3D Asset Modeling Specifications

To ensure smooth 60 FPS rendering in Three.js across modern browsers, all 3D assets must adhere to strict budget constraints:

| Specification | Standard | Notes |
|:---|:---|:---|
| **Format** | Binary glTF (`.glb`) | Self-contained textures and mesh |
| **Scale** | $1.0\text{ unit} = 1.0\text{ meter}$ | Critical for real-world collision calculation |
| **Origin Pivot** | Center-Bottom | Resting directly on $Y=0.0$ (floor level) |
| **Polygon Budget** | $\le 30,000$ triangles | Target range: 8k–20k polygons per item |
| **Compression** | Google Draco | Draco compression applied via GLTFLoader |
| **Materials** | PBR Metallic-Roughness | Albedo + Roughness/Metallic packed |
| **Texture Res** | $1024 \times 1024$ (Max 2048) | WebP or compressed PNG textures |

---

## 2. Blender Export Checklist

1. **Origin Check**: Ensure the 3D cursor is at world origin `(0, 0, 0)` and object origin is set to the bottom center of the bounding box.
2. **Transform Application**: Apply all transforms (`Ctrl+A` $\rightarrow$ *Apply All Transforms: Rotation & Scale*).
3. **Dimensions Verification**: Check Blender dimensions panel matches physical furniture specifications in cm.
4. **GLTF Export Settings**:
   * Format: `glTF Binary (.glb)`
   * Include: *Selected Objects*, *Apply Modifiers*
   * Transform: `+Y Up`
   * Geometry: *Compression (Draco)* enabled
5. **Storage Location**: Save `.blend` in `assets/blender/` and export `.glb` into `backend/storage/app/public/furniture/models/`.

---

## 3. Database Seeding Operations

Run the standard database seeders to populate initial furniture models and realistic dimensions:
```bash
cd backend
php artisan db:seed --class=CategorySeeder
php artisan db:seed --class=FurnitureSeeder
```
