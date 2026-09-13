#!/usr/bin/env python3
"""
SmartSpace - AI 3D Model Generator (CLI)
Powered by TripoSR (Stability AI & VAST AI Research)

Usage:
    python generate_glb.py --image input.jpg --sku COFF-001 --output COFF-001.glb
"""

import argparse
import os
import sys
import time
import numpy as np
from PIL import Image

def main():
    parser = argparse.ArgumentParser(description="Generate 3D GLB from 2D furniture image using TripoSR.")
    parser.add_argument("--image", type=str, required=True, help="Path to input 2D furniture image")
    parser.add_argument("--sku", type=str, default="MODEL-001", help="Furniture SKU (e.g. COFF-001)")
    parser.add_argument("--output", type=str, default=None, help="Output .glb path (defaults to <sku>.glb)")
    parser.add_argument("--mc-resolution", type=int, default=256, help="Marching cubes resolution (128-512)")
    parser.add_argument("--device", type=str, default="cuda:0", help="Torch device (cuda:0 or cpu)")
    parser.add_argument("--remove-bg", action="store_true", default=True, help="Automatically remove background")
    args = parser.parse_args()

    import torch
    import trimesh
    from tsr.system import TSR
    from tsr.utils import remove_background, resize_foreground

    device = args.device if torch.cuda.is_available() else "cpu"
    print(f"[*] SmartSpace 3D Generator running on device: {device}")

    output_path = args.output or f"{args.sku}.glb"

    if not os.path.exists(args.image):
        print(f"[!] Error: Image not found at {args.image}")
        sys.exit(1)

    print(f"[*] Loading input image: {args.image}")
    image = Image.open(args.image).convert("RGB")

    # Step 1: Background removal & centering
    if args.remove_bg:
        print("[*] Removing background with rembg...")
        image = remove_background(image)
        image = resize_foreground(image, ratio=0.85)

    # Step 2: Initialize TripoSR model
    print("[*] Initializing TripoSR neural reconstruction model...")
    t0 = time.time()
    model = TSR.from_pretrained(
        "stabilityai/TripoSR",
        config_name="config.yaml",
        weight_name="model.ckpt",
    )
    model.renderer.set_chunk_size(8192)
    model.to(device)

    # Step 3: Run feed-forward 3D inference
    print(f"[*] Generating 3D geometry for SKU: {args.sku}...")
    with torch.no_grad():
        scene_codes = model(image, device=device)

    # Step 4: Extract textured mesh
    print(f"[*] Extracting isosurface mesh (resolution={args.mc_resolution})...")
    meshes = model.extract_mesh(scene_codes, resolution=args.mc_resolution)
    mesh = meshes[0]

    # Convert to trimesh
    vertices = mesh.vertices.detach().cpu().numpy()
    faces = mesh.faces.detach().cpu().numpy()
    vertex_colors = mesh.vertex_colors.detach().cpu().numpy()

    # Convert RGB/RGBA [0, 1] to uint8 [0, 255]
    if vertex_colors.max() <= 1.0:
        vertex_colors = (vertex_colors * 255).astype(np.uint8)

    t_mesh = trimesh.Trimesh(
        vertices=vertices,
        faces=faces,
        vertex_colors=vertex_colors,
        process=True
    )

    # Orient mesh so it sits upright (+Y is up in Three.js)
    # TripoSR coordinates: center mesh at origin
    t_mesh.apply_translation(-t_mesh.centroid)

    # Export to GLB
    print(f"[*] Exporting GLB to: {output_path}")
    os.makedirs(os.path.dirname(output_path) if os.path.dirname(output_path) else ".", exist_ok=True)
    t_mesh.export(output_path, file_type="glb")

    elapsed = time.time() - t0
    file_size_mb = os.path.getsize(output_path) / (1024 * 1024)
    print(f"[✓] Successfully generated {output_path} ({file_size_mb:.2f} MB) in {elapsed:.1f}s!")
    print(f"[i] Copy this file to your SmartSpace project:")
    print(f"    backend/storage/app/public/furniture/models/{os.path.basename(output_path)}")
    print(f"[i] Then run: php artisan furniture:sync-models (or double-click sync-models.bat)")

if __name__ == "__main__":
    main()
