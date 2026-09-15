import bpy
import os
import math
from mathutils import Vector

MODELS_DIR = r"C:\xampp\htdocs\SmartSpace\backend\storage\app\public\furniture\models"
os.makedirs(MODELS_DIR, exist_ok=True)

def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def create_mat(name, color, roughness=0.5, metallic=0.0):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    if bsdf:
        bsdf.inputs['Base Color'].default_value = (*color, 1.0)
        bsdf.inputs['Roughness'].default_value = roughness
        bsdf.inputs['Metallic'].default_value = metallic
    return mat

def export_glb(sku):
    # Select all meshes and center on floor
    mesh_objs = [o for o in bpy.data.objects if o.type == 'MESH']
    if not mesh_objs:
        return
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
    for obj in mesh_objs:
        obj.location.x -= center.x
        obj.location.y -= center.y
        obj.location.z -= min_corner.z
    
    bpy.ops.object.select_all(action='SELECT')
    out_path = os.path.join(MODELS_DIR, f"{sku}.glb")
    bpy.ops.export_scene.gltf(filepath=out_path, export_format='GLB')
    print(f"Exported {sku}.glb ({os.path.getsize(out_path)} bytes)")

# 1. BED-003: Skan King Hydraulic Storage Bed (194x216x105 cm)
def gen_bed_003():
    reset_scene()
    w, d, h = 1.94, 2.16, 1.05
    mat_oak = create_mat('LightOak', (0.75, 0.62, 0.48), 0.55)
    mat_fabric = create_mat('GreyFabric', (0.6, 0.62, 0.64), 0.8)
    mat_mattress = create_mat('WhiteMattress', (0.94, 0.94, 0.93), 0.7)
    
    # Storage Base
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.08, 0.2))
    base = bpy.context.active_object
    base.scale = (w, d*0.92, 0.38)
    bpy.ops.object.transform_apply(scale=True)
    base.data.materials.append(mat_oak)
    
    # Mattress
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.08, 0.48))
    matt = bpy.context.active_object
    matt.scale = (w*0.92, d*0.86, 0.26)
    bpy.ops.object.transform_apply(scale=True)
    matt.data.materials.append(mat_mattress)
    
    # Padded Headboard
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, d*0.5 - 0.08, h*0.5))
    head = bpy.context.active_object
    head.scale = (w*1.02, 0.16, h)
    bpy.ops.object.transform_apply(scale=True)
    head.data.materials.append(mat_fabric)
    
    # Pillows
    for s in [-0.45, 0.45]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(s, d*0.5 - 0.42, 0.66))
        p = bpy.context.active_object
        p.scale = (0.68, 0.42, 0.14)
        p.rotation_euler = (math.radians(-15), 0, 0)
        bpy.ops.object.transform_apply(scale=True, rotation=True)
        p.data.materials.append(mat_mattress)
    export_glb('BED-003')

# 2. BED-004: Zen Low Tatami Platform King (210x220x30 cm)
def gen_bed_004():
    reset_scene()
    w, d, h = 2.10, 2.20, 0.30
    mat_cedar = create_mat('CedarWood', (0.45, 0.32, 0.22), 0.6)
    mat_tatami = create_mat('TatamiRush', (0.72, 0.70, 0.52), 0.85)
    mat_futon = create_mat('NaturalCotton', (0.92, 0.90, 0.86), 0.8)
    
    # Wide low platform
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.08))
    plat = bpy.context.active_object
    plat.scale = (w, d, 0.14)
    bpy.ops.object.transform_apply(scale=True)
    plat.data.materials.append(mat_cedar)
    
    # Tatami inlay
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.05, 0.16))
    tatami = bpy.context.active_object
    tatami.scale = (w*0.88, d*0.82, 0.04)
    bpy.ops.object.transform_apply(scale=True)
    tatami.data.materials.append(mat_tatami)
    
    # Low Futon Mattress
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.05, 0.26))
    futon = bpy.context.active_object
    futon.scale = (w*0.78, d*0.72, 0.18)
    bpy.ops.object.transform_apply(scale=True)
    futon.data.materials.append(mat_futon)
    
    # Minimal Low Headboard
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, d*0.5 - 0.06, 0.28))
    hb = bpy.context.active_object
    hb.scale = (w*0.9, 0.1, 0.35)
    bpy.ops.object.transform_apply(scale=True)
    hb.data.materials.append(mat_cedar)
    export_glb('BED-004')

# 3. COFF-003: Factory Round Nesting Tables (80x80x45 cm)
def gen_coff_003():
    reset_scene()
    mat_teak = create_mat('TeakWood', (0.55, 0.38, 0.24), 0.5)
    mat_metal = create_mat('DarkMetal', (0.15, 0.15, 0.16), 0.3, 0.8)
    
    # Table 1: Large (dia 0.80, height 0.45)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.40, depth=0.03, location=(0, 0, 0.435))
    t1 = bpy.context.active_object
    t1.data.materials.append(mat_teak)
    for a in [0, 120, 240]:
        rad = math.radians(a)
        bpy.ops.mesh.primitive_cylinder_add(radius=0.012, depth=0.43, location=(math.cos(rad)*0.35, math.sin(rad)*0.35, 0.215))
        leg = bpy.context.active_object
        leg.data.materials.append(mat_metal)
        
    # Table 2: Small (dia 0.55, height 0.36, shifted slightly)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.28, depth=0.025, location=(0.28, -0.15, 0.35))
    t2 = bpy.context.active_object
    t2.data.materials.append(mat_teak)
    for a in [60, 180, 300]:
        rad = math.radians(a)
        bpy.ops.mesh.primitive_cylinder_add(radius=0.012, depth=0.34, location=(0.28 + math.cos(rad)*0.24, -0.15 + math.sin(rad)*0.24, 0.17))
        leg = bpy.context.active_object
        leg.data.materials.append(mat_metal)
    export_glb('COFF-003')

# 4. COFF-004: Verona Marble Rectangular Coffee Table (120x65x40 cm)
def gen_coff_004():
    reset_scene()
    w, d, h = 1.20, 0.65, 0.40
    mat_marble = create_mat('CarraraMarble', (0.92, 0.92, 0.93), 0.25)
    mat_brass = create_mat('SatinBrass', (0.85, 0.70, 0.38), 0.35, 0.9)
    
    # Marble slab
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, h - 0.015))
    slab = bpy.context.active_object
    slab.scale = (w, d, 0.03)
    bpy.ops.object.transform_apply(scale=True)
    slab.data.materials.append(mat_marble)
    
    # Brass base perimeter
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, h - 0.04))
    sub = bpy.context.active_object
    sub.scale = (w*0.96, d*0.94, 0.02)
    bpy.ops.object.transform_apply(scale=True)
    sub.data.materials.append(mat_brass)
    
    # 4 Brass legs
    for sx in [-w*0.45, w*0.45]:
        for sy in [-d*0.44, d*0.44]:
            bpy.ops.mesh.primitive_cylinder_add(radius=0.015, depth=h - 0.05, location=(sx, sy, (h-0.05)*0.5))
            leg = bpy.context.active_object
            leg.data.materials.append(mat_brass)
    export_glb('COFF-004')

# 5. TV-001: Horizon 180 Floating Wall Console (180x38x32 cm)
def gen_tv_001():
    reset_scene()
    w, d, h = 1.80, 0.38, 0.32
    mat_oak = create_mat('NaturalOak', (0.72, 0.58, 0.42), 0.5)
    mat_black = create_mat('MatteBlack', (0.12, 0.12, 0.12), 0.4)
    
    # Cabinet body
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, h*0.5 + 0.15))
    cab = bpy.context.active_object
    cab.scale = (w, d, h)
    bpy.ops.object.transform_apply(scale=True)
    cab.data.materials.append(mat_oak)
    
    # 3 Slatted door panels
    door_w = (w - 0.08) / 3
    for i in [-1, 0, 1]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(i * (door_w + 0.02), -d*0.5 - 0.008, h*0.5 + 0.15))
        door = bpy.context.active_object
        door.scale = (door_w, 0.015, h * 0.9)
        bpy.ops.object.transform_apply(scale=True)
        door.data.materials.append(mat_oak)
    export_glb('TV-001')

# 6. TV-003: Brooklyn Steel-Mesh Credenza (160x42x65 cm)
def gen_tv_003():
    reset_scene()
    w, d, h = 1.60, 0.42, 0.65
    mat_walnut = create_mat('WalnutTop', (0.42, 0.28, 0.18), 0.45)
    mat_mesh = create_mat('SteelMesh', (0.2, 0.21, 0.22), 0.4, 0.7)
    
    # Walnut Top Slab
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, h - 0.015))
    top = bpy.context.active_object
    top.scale = (w, d, 0.03)
    bpy.ops.object.transform_apply(scale=True)
    top.data.materials.append(mat_walnut)
    
    # Steel frame
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, (h - 0.18)*0.5 + 0.15))
    body = bpy.context.active_object
    body.scale = (w*0.98, d*0.96, h - 0.2)
    bpy.ops.object.transform_apply(scale=True)
    body.data.materials.append(mat_mesh)
    
    # 4 Legs
    for sx in [-w*0.45, w*0.45]:
        for sy in [-d*0.44, d*0.44]:
            bpy.ops.mesh.primitive_cylinder_add(radius=0.018, depth=0.16, location=(sx, sy, 0.08))
            leg = bpy.context.active_object
            leg.data.materials.append(mat_mesh)
    export_glb('TV-003')

# 7. NST-002: Linnea 2-Drawer Oak Nightstand (48x40x52 cm)
def gen_nst_002():
    reset_scene()
    w, d, h = 0.48, 0.40, 0.52
    mat_oak = create_mat('OakWood', (0.76, 0.64, 0.48), 0.5)
    mat_brass = create_mat('BrassKnob', (0.85, 0.72, 0.35), 0.3, 0.9)
    
    # Cabinet box
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, h*0.5 + 0.1))
    cab = bpy.context.active_object
    cab.scale = (w, d, h*0.65)
    bpy.ops.object.transform_apply(scale=True)
    cab.data.materials.append(mat_oak)
    
    # 2 Drawer faces & knobs
    for z in [h*0.5 - 0.04, h*0.5 + 0.14]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -d*0.5 - 0.005, z))
        df = bpy.context.active_object
        df.scale = (w*0.92, 0.012, h*0.28)
        bpy.ops.object.transform_apply(scale=True)
        df.data.materials.append(mat_oak)
        
        bpy.ops.mesh.primitive_cylinder_add(radius=0.012, depth=0.02, location=(0, -d*0.5 - 0.02, z))
        knob = bpy.context.active_object
        knob.rotation_euler = (math.radians(90), 0, 0)
        bpy.ops.object.transform_apply(rotation=True)
        knob.data.materials.append(mat_brass)
        
    # 4 Legs
    for sx in [-w*0.4, w*0.4]:
        for sy in [-d*0.38, d*0.38]:
            bpy.ops.mesh.primitive_cylinder_add(radius=0.014, depth=0.2, location=(sx, sy, 0.1))
            leg = bpy.context.active_object
            leg.data.materials.append(mat_oak)
    export_glb('NST-002')

# 8. NST-003: Foundry Open Wire Bedside Cube (42x42x48 cm)
def gen_nst_003():
    reset_scene()
    w, d, h = 0.42, 0.42, 0.48
    mat_wood = create_mat('NaturalTeak', (0.62, 0.45, 0.3), 0.5)
    mat_iron = create_mat('BlackIron', (0.14, 0.14, 0.14), 0.4, 0.8)
    
    # Wood Top
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, h - 0.015))
    top = bpy.context.active_object
    top.scale = (w, d, 0.03)
    bpy.ops.object.transform_apply(scale=True)
    top.data.materials.append(mat_wood)
    
    # Bottom wire shelf
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.12))
    shelf = bpy.context.active_object
    shelf.scale = (w*0.9, d*0.9, 0.015)
    bpy.ops.object.transform_apply(scale=True)
    shelf.data.materials.append(mat_iron)
    
    # 4 Wire corner posts
    for sx in [-w*0.45, w*0.45]:
        for sy in [-d*0.45, d*0.45]:
            bpy.ops.mesh.primitive_cylinder_add(radius=0.008, depth=h - 0.03, location=(sx, sy, (h-0.03)*0.5))
            post = bpy.context.active_object
            post.data.materials.append(mat_iron)
    export_glb('NST-003')

# 9. NST-004: Grace Fluted Cylinder Pedestal (40x40x50 cm)
def gen_nst_004():
    reset_scene()
    r, h = 0.20, 0.50
    mat_fluted = create_mat('OatmealFluted', (0.86, 0.83, 0.78), 0.65)
    mat_top = create_mat('CalacattaTop', (0.94, 0.94, 0.95), 0.25)
    
    # Fluted Cylinder Body (32 sides)
    bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=r, depth=h - 0.025, location=(0, 0, (h-0.025)*0.5))
    body = bpy.context.active_object
    body.data.materials.append(mat_fluted)
    
    # Marble Disc Top
    bpy.ops.mesh.primitive_cylinder_add(vertices=48, radius=r*1.02, depth=0.025, location=(0, 0, h - 0.012))
    top = bpy.context.active_object
    top.data.materials.append(mat_top)
    export_glb('NST-004')

# 10. DSK-003: Architect Drafting Studio Desk (150x75x85 cm)
def gen_dsk_003():
    reset_scene()
    w, d, h = 1.50, 0.75, 0.85
    mat_oak = create_mat('DraftingOak', (0.75, 0.60, 0.44), 0.5)
    mat_metal = create_mat('BlackTrestle', (0.15, 0.15, 0.16), 0.35, 0.7)
    
    # Desktop
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, h - 0.02))
    top = bpy.context.active_object
    top.scale = (w, d, 0.04)
    bpy.ops.object.transform_apply(scale=True)
    top.data.materials.append(mat_oak)
    
    # Two Trestle Legs (A-frame)
    for sx in [-w*0.38, w*0.38]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx, 0, (h - 0.04)*0.5))
        tr = bpy.context.active_object
        tr.scale = (0.06, d*0.85, h - 0.04)
        bpy.ops.object.transform_apply(scale=True)
        tr.data.materials.append(mat_metal)
    export_glb('DSK-003')

# 11. DSK-004: Executive L-Shaped Corner Workstation (180x160x75 cm)
def gen_dsk_004():
    reset_scene()
    mat_walnut = create_mat('ExecutiveWalnut', (0.38, 0.25, 0.16), 0.45)
    mat_frame = create_mat('DarkGraphite', (0.16, 0.17, 0.18), 0.35, 0.6)
    
    # Main desk (1.80 x 0.75)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.73))
    main_top = bpy.context.active_object
    main_top.scale = (1.80, 0.75, 0.04)
    bpy.ops.object.transform_apply(scale=True)
    main_top.data.materials.append(mat_walnut)
    
    # Return desk (0.60 x 0.85 attached to right)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.60, 0.78, 0.73))
    ret_top = bpy.context.active_object
    ret_top.scale = (0.60, 0.85, 0.04)
    bpy.ops.object.transform_apply(scale=True)
    ret_top.data.materials.append(mat_walnut)
    
    # 5 Sturdy legs
    leg_coords = [(-0.85, -0.32), (-0.85, 0.32), (0.85, -0.32), (0.85, 1.15), (0.35, 1.15)]
    for x, y in leg_coords:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(x, y, 0.35))
        leg = bpy.context.active_object
        leg.scale = (0.05, 0.05, 0.70)
        bpy.ops.object.transform_apply(scale=True)
        leg.data.materials.append(mat_frame)
    export_glb('DSK-004')

# 12. DCH-006: Heritage Oak Dining Bench 140cm (140x36x46 cm)
def gen_dch_006():
    reset_scene()
    w, d, h = 1.40, 0.36, 0.46
    mat_oak = create_mat('HeritageOak', (0.70, 0.55, 0.38), 0.55)
    
    # Solid plank top
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, h - 0.02))
    plank = bpy.context.active_object
    plank.scale = (w, d, 0.04)
    bpy.ops.object.transform_apply(scale=True)
    plank.data.materials.append(mat_oak)
    
    # 4 Angled legs
    for sx in [-w*0.42, w*0.42]:
        for sy in [-d*0.35, d*0.35]:
            bpy.ops.mesh.primitive_cylinder_add(radius=0.022, depth=h - 0.04, location=(sx, sy, (h-0.04)*0.5))
            leg = bpy.context.active_object
            leg.data.materials.append(mat_oak)
    export_glb('DCH-006')

# 13. STG-001: Gridline Tall Open Modular Bookcase (90x34x190 cm)
def gen_stg_001():
    reset_scene()
    w, d, h = 0.90, 0.34, 1.90
    mat_oak = create_mat('BookcaseOak', (0.74, 0.60, 0.45), 0.55)
    
    # 2 Side uprights
    for sx in [-w*0.5 + 0.015, w*0.5 - 0.015]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx, 0, h*0.5))
        side = bpy.context.active_object
        side.scale = (0.03, d, h)
        bpy.ops.object.transform_apply(scale=True)
        side.data.materials.append(mat_oak)
        
    # 5 Shelves
    for i in range(5):
        z = 0.05 + i * (h - 0.1) / 4
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, z))
        sh = bpy.context.active_object
        sh.scale = (w - 0.06, d, 0.03)
        bpy.ops.object.transform_apply(scale=True)
        sh.data.materials.append(mat_oak)
    export_glb('STG-001')

# 14. STG-002: Lattice Timber Room Divider / Screen (120x30x175 cm)
def gen_stg_002():
    reset_scene()
    w, d, h = 1.20, 0.30, 1.75
    mat_cedar = create_mat('CedarSlat', (0.58, 0.42, 0.28), 0.6)
    
    # 3 Accordion panels
    pw = w / 3
    for i, angle in enumerate([-18, 18, -18]):
        x = -w*0.5 + pw*0.5 + i*pw
        y = math.sin(math.radians(angle)) * 0.12
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(x, y, h*0.5))
        p = bpy.context.active_object
        p.scale = (pw*0.94, 0.025, h)
        p.rotation_euler = (0, 0, math.radians(angle))
        bpy.ops.object.transform_apply(scale=True, rotation=True)
        p.data.materials.append(mat_cedar)
    export_glb('STG-002')

# 15. STG-004: Foyer Entryway Bench & Coat Rack (100x40x180 cm)
def gen_stg_004():
    reset_scene()
    w, d, h = 1.00, 0.40, 1.80
    mat_wood = create_mat('BenchOak', (0.75, 0.62, 0.46), 0.55)
    mat_black = create_mat('RackSteel', (0.15, 0.15, 0.16), 0.35, 0.8)
    
    # Bench Seat
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.45))
    bench = bpy.context.active_object
    bench.scale = (w, d, 0.04)
    bpy.ops.object.transform_apply(scale=True)
    bench.data.materials.append(mat_wood)
    
    # Shoe shelf underneath
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.15))
    shoe = bpy.context.active_object
    shoe.scale = (w*0.92, d*0.85, 0.02)
    bpy.ops.object.transform_apply(scale=True)
    shoe.data.materials.append(mat_black)
    
    # Upright frame at back
    for sx in [-w*0.45, w*0.45]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.015, depth=h, location=(sx, d*0.45, h*0.5))
        post = bpy.context.active_object
        post.data.materials.append(mat_black)
        
    # Top shelf
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, d*0.4, h - 0.05))
    top_sh = bpy.context.active_object
    top_sh.scale = (w, 0.25, 0.02)
    bpy.ops.object.transform_apply(scale=True)
    top_sh.data.materials.append(mat_wood)
    
    # Coat hooks
    for i in range(5):
        x = -w*0.35 + i * (w*0.7)/4
        bpy.ops.mesh.primitive_cylinder_add(radius=0.01, depth=0.08, location=(x, d*0.42, h - 0.35))
        hook = bpy.context.active_object
        hook.rotation_euler = (math.radians(90), 0, 0)
        bpy.ops.object.transform_apply(rotation=True)
        hook.data.materials.append(mat_black)
    export_glb('STG-004')

def main():
    print("Generating all 15 remaining models...")
    gen_bed_003()
    gen_bed_004()
    gen_coff_003()
    gen_coff_004()
    gen_tv_001()
    gen_tv_003()
    gen_nst_002()
    gen_nst_003()
    gen_nst_004()
    gen_dsk_003()
    gen_dsk_004()
    gen_dch_006()
    gen_stg_001()
    gen_stg_002()
    gen_stg_004()
    print("ALL 15 MODELS GENERATED SUCCESSFULLY!")

if __name__ == "__main__":
    main()
