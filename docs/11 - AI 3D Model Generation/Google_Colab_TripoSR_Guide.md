# 🛋️ Google Colab AI 3D Model Generation Guide (Option B)

This document provides a complete guide for generating textured 3D `.glb` furniture models from 2D photos using **Google Colab's free T4 GPU** and importing them directly into SmartSpace.

---

## 1. Executive Summary

| Attribute | Details |
|---|---|
| **Branch** | `ai` |
| **Model Engine** | [TripoSR](https://github.com/VAST-AI-Research/TripoSR) (Stability AI & VAST AI Research) |
| **Compute Environment** | Google Colab (Free NVIDIA Tesla T4 GPU, 15GB VRAM) |
| **Generation Time** | ~5 to 10 seconds per furniture item |
| **Output Format** | Standard binary glTF (`.glb`) with vertex texturing |
| **Local Requirement** | Zero GPU required on user's machine (runs 100% in cloud) |

---

## 2. Architecture & Spatial Truth Flow

A common critique in academic defenses is that **AI-generated 3D meshes have arbitrary scale and cannot guarantee real-world physical dimensions**.

SmartSpace solves this with a **Two-Tier Perceptual + Deterministic Pipeline**:

```
[2D Catalog Photo / Upload]
       │
       ▼
[Google Colab (TripoSR on T4 GPU)]
       │  • Neural Radiance / Triplane prediction
       │  • Marching cubes isosurface extraction (256^3)
       │  • Vertex color baking
       ▼
[Textured .GLB Mesh]
       │
       ▼
[SmartSpace Local Storage] (backend/storage/app/public/furniture/models/<SKU>.glb)
       │
       ▼
[sync-models.bat] (Links GLB to Furniture catalog record in DB)
       │
       ▼
[Three.js useModelLoader.ts]
       │  • Reads catalog width_cm, depth_cm, height_cm
       │  • Computes initial bounding box of raw AI mesh
       │  • Rescales geometries: scaleX = targetW/origW, scaleY = targetH/origH, scaleZ = targetD/origD
       │  • Centers X/Z on origin and rests base on floor (Y = 0)
       │  • Locks root scale to (1.000, 1.000, 1.000)
       ▼
[Room Planner & Deterministic Collision Engine]
       │  • Evaluates OBB/AABB collision, boundary breaches, clearance envelopes
       ▼
[Physical Certification Guarantee]
```

---

## 3. Step-by-Step Instructions

### Step 1: Open Google Colab
1. In your browser, navigate to [Google Colab](https://colab.research.google.com).
2. Click **Upload** and choose the notebook from your SmartSpace project:
   - Location: `colab/SmartSpace_AI_3D_Generator.ipynb` (or `SmartSpace_AI_3D_Generator.ipynb` in project root).

### Step 2: Enable Free GPU
1. In the top menu of Google Colab, go to **Runtime** > **Change runtime type**.
2. Under **Hardware accelerator**, select **T4 GPU**.
3. Click **Save**.

### Step 3: Run Setup & Load Model
1. Run **Cell 1**: Clones TripoSR and installs dependencies.
2. Run **Cell 2**: Downloads the pretrained weights (`stabilityai/TripoSR`) to the T4 GPU.

### Step 4: Select Furniture or Upload Photo
1. In **Cell 3**, choose one of the preset SmartSpace catalog items:
   - `COFF-001 (Coffee Table)`
   - `DCH-001 (Dining Chair)`
   - `SOFA-002 (Modern Loveseat)`
   - `TV-001 (TV Media Console)`
   - Or choose `CUSTOM_UPLOAD` to upload your own picture.
2. Ensure the `custom_sku` matches the catalog SKU you wish to replace or populate.

### Step 5: Generate & Inspect in 3D
1. Run **Cell 4**: TripoSR generates the 3D geometry in ~5-10 seconds and saves `<SKU>.glb`.
2. Run **Cell 5**: An interactive 3D viewer will load inside the notebook. You can rotate (left click + drag), pan (right click), and zoom (scroll wheel) to verify the 3D quality.

### Step 6: Download & Import to SmartSpace
1. Run **Cell 6**: Colab will automatically download `<SKU>.glb` (e.g., `COFF-001.glb`).
2. Move the downloaded file into your SmartSpace storage folder:
   ```
   SmartSpace\backend\storage\app\public\furniture\models\<SKU>.glb
   ```
3. Double-click `sync-models.bat` in the root of the SmartSpace project (or run `php artisan furniture:sync-models`).
4. You will see the CLI confirmation:
   ```
   ▶ SYNCHRONIZED 3D GLB MODELS
   +----------+--------------------+--------------+-----------+--------------+-----------------+
   | SKU      | Name               | Dimensions   | File Size | GLB Filename | Status          |
   +----------+--------------------+--------------+-----------+--------------+-----------------+
   | COFF-001 | Aero Coffee Table  | 120x60x45 cm | 3.20 MB   | COFF-001.glb | Linked / Active |
   +----------+--------------------+--------------+-----------+--------------+-----------------+
   ```
5. Refresh your SmartSpace browser tab (`http://localhost:5173/room-planner` or furniture details page). The real 3D model will immediately replace the procedural fallback!

---

## 4. Capstone Defense Presentation & FAQ

### Panel Question 1: "Why not generate 3D models on the user's laptop?"
> *"Local neural 3D reconstruction models like TripoSR require high-performance NVIDIA GPUs with at least 6-8 GB of VRAM and specialized CUDA compute capability. Consumer hardware, including the defense presentation device (AMD Radeon Integrated Graphics with 2GB shared memory), cannot allocate the tensors required for feed-forward 3D diffusion without system crashes. By utilizing an automated cloud GPU pipeline (Option B), we achieve 5-second generation speeds without forcing client-side hardware overhead."*

### Panel Question 2: "Doesn't AI 3D generation produce random scales that break collision detection?"
> *"That would indeed break collision detection if the raw mesh were used blindly. However, SmartSpace treats AI 3D generation strictly as a **surface topology perception layer**. Upon loading into Three.js, our `useModelLoader.ts` normalizer computes the initial mesh dimensions and applies axis-specific scaling transformations that precisely lock the object to the verified catalog dimensions (`width_cm`, `depth_cm`, `height_cm`). Collision checks and clearance calculations in Laravel are always performed against these certified dimensions, meaning AI enhances visualization without compromising spatial truth."*

---

## 5. File Manifest for AI Branch

| File | Purpose |
|---|---|
| [`SmartSpace_AI_3D_Generator.ipynb`](../../SmartSpace_AI_3D_Generator.ipynb) | Turnkey Google Colab notebook for free T4 GPU generation |
| [`colab/generate_glb.py`](../../colab/generate_glb.py) | CLI Python script for batch cloud generation |
| [`backend/app/Console/Commands/SyncFurnitureModels.php`](../../backend/app/Console/Commands/SyncFurnitureModels.php) | Artisan command to detect and link GLBs to database |
| [`sync-models.bat`](../../sync-models.bat) | 1-click Windows synchronizer for local testing |
| [`docs/11 - AI 3D Model Generation/Google_Colab_TripoSR_Guide.md`](./Google_Colab_TripoSR_Guide.md) | This technical documentation and defense guide |
