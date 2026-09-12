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

---

## 4. Automated OBJ/FBX to Web-Ready Draco GLB Pipeline

High-poly 3D artist files (`.obj`, `.fbx`) downloaded from libraries often have $500\text{k} - 1.5\text{M}$ polygons, which exceed web browser capabilities. We use headless Blender 5.2 LTS to automate decimation, PBR texture binding, and Draco compression:

### Headless Conversion Script Example (`convert_asset.py`):
```python
import bpy, os

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.wm.obj_import(filepath=r"assets/couch.obj")

obj = bpy.context.selected_objects[0]
bpy.context.view_layer.objects.active = obj

# Decimate to ~100,000 polygons for optimal 60 FPS WebGL
if len(obj.data.polygons) > 120000:
    ratio = max(0.05, 100000 / len(obj.data.polygons))
    mod = obj.modifiers.new(name="Decimate", type='DECIMATE')
    mod.ratio = ratio
    bpy.ops.object.modifier_apply(modifier="Decimate")

bpy.ops.object.shade_smooth()

# Create PBR Principled BSDF Material with texture maps
mat = bpy.data.materials.new(name="PBRMaterial")
mat.use_nodes = True
bsdf = mat.node_tree.nodes.get("Principled BSDF")

tex_diffuse = mat.node_tree.nodes.new('ShaderNodeTexImage')
tex_diffuse.image = bpy.data.images.load(r"assets/fabric_diffuse.jpg")
mat.node_tree.links.new(tex_diffuse.outputs['Color'], bsdf.inputs['Base Color'])

obj.data.materials.clear()
obj.data.materials.append(mat)

# Export Draco-compressed GLB
bpy.ops.export_scene.gltf(
    filepath=r"backend/storage/app/public/furniture/models/SOFA-001.glb",
    export_format='GLB',
    export_draco_mesh_compression_enable=True,
    export_apply=True,
    export_yup=True
)
```

Run via CLI:
```bash
"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" --background --python convert_asset.py
```

---

## 5. Automated Showroom Studio Photo Rendering

When 2D product photography is unavailable, product images can be rendered directly from the certified 3D model in Blender with three-point studio lighting and transparent alpha cutouts:

```python
# Camera at balanced catalog distance (~75-80% frame coverage)
scene = bpy.context.scene
scene.render.film_transparent = True  # Clean alpha cutout for luxury web cards
scene.render.resolution_x = 1200
scene.render.resolution_y = 800
scene.render.image_settings.file_format = 'WEBP'
scene.render.image_settings.quality = 92

# Three-point studio lighting
# 1. Key Light (warm 45° key, 300W)
# 2. Fill Light (soft cool fill, 120W)
# 3. Rim Light (accent silhouette, 150W)

# Camera shots:
shots = [
    ("SOFA-001-primary.webp", (2.5, -3.3, 1.35)),  # 3/4 Perspective
    ("SOFA-001-front.webp",   (0.0, -3.7, 0.75)),  # Front Elevation
    ("SOFA-001-side.webp",    (-3.3, -1.6, 1.10)), # Side Profile
]
```

Images are stored in `backend/storage/app/public/furniture/images/{SKU}-*.webp` and served through the Vite `/storage` proxy.
