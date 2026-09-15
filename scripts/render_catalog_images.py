import bpy
import os
import sys
import math
from mathutils import Vector

def render_model(glb_path, out_webp_path):
    print(f"\n==========================================")
    print(f"Rendering: {os.path.basename(glb_path)}")
    print(f"Output:    {out_webp_path}")

    bpy.ops.wm.read_factory_settings(use_empty=True)

    try:
        bpy.ops.import_scene.gltf(filepath=glb_path)
    except Exception as e:
        print(f"ERROR importing {glb_path}: {e}")
        return False

    mesh_objs = [o for o in bpy.data.objects if o.type == 'MESH']
    if not mesh_objs:
        print(f"No mesh objects found in {glb_path}")
        return False

    # Calculate global bounding box
    min_corner = Vector((float('inf'), float('inf'), float('inf')))
    max_corner = Vector((float('-inf'), float('-inf'), float('-inf')))

    for obj in mesh_objs:
        for corner in obj.bound_box:
            world_corner = obj.matrix_world @ Vector(corner)
            min_corner.x = min(min_corner.x, world_corner.x)
            min_corner.y = min(min_corner.y, world_corner.y)
            min_corner.z = min(min_corner.z, world_corner.z)
            max_corner.x = max(max_corner.x, world_corner.x)
            max_corner.y = max(max_corner.y, world_corner.y)
            max_corner.z = max(max_corner.z, world_corner.z)

    center = (min_corner + max_corner) / 2
    size = max_corner - min_corner
    max_dim = max(size.x, size.y, size.z)

    if max_dim <= 0.0001:
        print(f"Invalid dimensions for {glb_path}")
        return False

    # Center all objects at origin, with bottom resting on z=0
    for obj in mesh_objs:
        obj.location.x -= center.x
        obj.location.y -= center.y
        obj.location.z -= min_corner.z

    # Create Camera
    cam_data = bpy.data.cameras.new('StudioCam')
    cam_data.lens = 55
    cam_data.clip_start = 0.001
    cam_data.clip_end = max(100000.0, max_dim * 20.0)
    cam_obj = bpy.data.objects.new('StudioCam', cam_data)
    bpy.context.collection.objects.link(cam_obj)
    bpy.context.scene.camera = cam_obj

    # 3/4 Studio angle
    dist = max_dim * 1.55
    cam_obj.location = Vector((dist * 0.85, -dist * 1.15, dist * 0.72))
    target = Vector((0, 0, size.z * 0.42))
    direction = target - cam_obj.location
    cam_obj.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

    # World Lighting
    world = bpy.data.worlds.new('StudioWorld')
    world.use_nodes = True
    bg = world.node_tree.nodes.get('Background')
    if bg:
        bg.inputs['Color'].default_value = (1.0, 1.0, 1.0, 1.0)
        bg.inputs['Strength'].default_value = 0.85
    bpy.context.scene.world = world

    # Three-point studio lighting
    key_data = bpy.data.lights.new('KeyLight', 'SUN')
    key_data.energy = 3.2
    key_obj = bpy.data.objects.new('KeyLight', key_data)
    bpy.context.collection.objects.link(key_obj)
    key_obj.rotation_euler = (math.radians(52), math.radians(12), math.radians(-38))

    fill_data = bpy.data.lights.new('FillLight', 'SUN')
    fill_data.energy = 1.9
    fill_obj = bpy.data.objects.new('FillLight', fill_data)
    bpy.context.collection.objects.link(fill_obj)
    fill_obj.rotation_euler = (math.radians(38), math.radians(-18), math.radians(125))

    rim_data = bpy.data.lights.new('RimLight', 'SUN')
    rim_data.energy = 1.5
    rim_obj = bpy.data.objects.new('RimLight', rim_data)
    bpy.context.collection.objects.link(rim_obj)
    rim_obj.rotation_euler = (math.radians(65), math.radians(0), math.radians(-155))

    # Render settings
    scene = bpy.context.scene
    scene.render.film_transparent = True
    scene.render.resolution_x = 800
    scene.render.resolution_y = 600
    scene.render.image_settings.file_format = 'WEBP'
    scene.render.image_settings.quality = 92
    scene.render.filepath = out_webp_path

    try:
        scene.render.engine = 'BLENDER_EEVEE_NEXT'
    except:
        scene.render.engine = 'BLENDER_EEVEE'

    os.makedirs(os.path.dirname(out_webp_path), exist_ok=True)
    bpy.ops.render.render(write_still=True)
    print(f"SUCCESS: Rendered {out_webp_path} ({os.path.getsize(out_webp_path)} bytes)")
    return True

def main():
    models_dir = r"C:\xampp\htdocs\SmartSpace\backend\storage\app\public\furniture\models"
    images_dir = r"C:\xampp\htdocs\SmartSpace\backend\storage\app\public\furniture\images"

    glb_files = [f for f in os.listdir(models_dir) if f.lower().endswith(".glb")]
    print(f"Found {len(glb_files)} GLB models to render.")

    success_count = 0
    for glb_name in sorted(glb_files):
        sku = os.path.splitext(glb_name)[0]
        glb_path = os.path.join(models_dir, glb_name)
        out_webp_path = os.path.join(images_dir, f"{sku}-primary.webp")
        if render_model(glb_path, out_webp_path):
            success_count += 1

    print(f"\nAll Done! Rendered {success_count}/{len(glb_files)} models to {images_dir}.")

if __name__ == "__main__":
    main()
