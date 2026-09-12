import os
import json
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

INPUT_JSON = os.path.abspath("../backend/storage/furniture_items.json")
OUTPUT_DIR = os.path.abspath("../backend/storage/app/public/furniture/images")

os.makedirs(OUTPUT_DIR, exist_ok=True)

def hex_to_rgb(hex_str):
    hex_str = hex_str.lstrip("#")
    if len(hex_str) == 3:
        hex_str = "".join([c * 2 for c in hex_str])
    return tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))

def adjust_color(rgb, factor):
    return tuple(max(0, min(255, int(c * factor))) for c in rgb)

def draw_iso_box(draw, origin_x, origin_y, w, d, h, base_color, leg_color=None):
    """
    Draws an isometric box.
    origin_x, origin_y: bottom-center base coordinate
    w: visual width in px
    d: visual depth in px
    h: visual height in px
    """
    top_color = adjust_color(base_color, 1.18)
    front_color = base_color
    side_color = adjust_color(base_color, 0.75)

    # Isometric projection vectors
    # X vector: (+cos(30), -sin(30)) -> (+0.866, -0.5)
    # Z vector (depth): (-cos(30), -sin(30)) -> (-0.866, -0.5)
    # Y vector (height): (0, -1)
    cos30 = 0.866
    sin30 = 0.5

    hw = (w / 2) * cos30
    hd = (d / 2) * cos30
    h_dy = (d / 2) * sin30
    w_dy = (w / 2) * sin30

    bx = origin_x
    by = origin_y

    # Base polygon vertices
    # Center-bottom: (bx, by)
    # Right-bottom: (bx + hw, by - w_dy)
    # Back-bottom: (bx + hw - hd, by - w_dy - h_dy)
    # Left-bottom: (bx - hd, by - h_dy)

    # Top vertices (shifted up by h)
    p_center_top = (bx, by - h)
    p_right_top = (bx + hw, by - w_dy - h)
    p_back_top = (bx + hw - hd, by - w_dy - h_dy - h)
    p_left_top = (bx - hd, by - h_dy - h)

    p_center_bot = (bx, by)
    p_right_bot = (bx + hw, by - w_dy)
    p_left_bot = (bx - hd, by - h_dy)

    # Draw front-right face
    draw.polygon([p_center_bot, p_right_bot, p_right_top, p_center_top], fill=front_color)
    # Draw front-left face
    draw.polygon([p_center_bot, p_left_bot, p_left_top, p_center_top], fill=side_color)
    # Draw top face
    draw.polygon([p_center_top, p_right_top, p_back_top, p_left_top], fill=top_color)

def generate_image(item):
    sku = item["sku"]
    dest_path = os.path.join(OUTPUT_DIR, f"{sku}-primary.webp")
    
    # Don't overwrite existing high-res photographic renders like SOFA-001 if size is large
    if os.path.exists(dest_path) and sku == "SOFA-001":
        print(f"Skipping existing render for {sku}")
        return

    width, height = 1200, 800
    img = Image.new("RGBA", (width, height), (255, 255, 255, 255))
    
    # 1. Elegant Studio Background Gradient
    # Soft warm lighting from top-center
    bg = Image.new("RGBA", (width, height))
    bg_draw = ImageDraw.Draw(bg)
    for y in range(height):
        # Subtle gradient from #F8FAFC (248, 250, 252) to #E2E8F0 (226, 232, 240)
        ratio = y / height
        r = int(248 - ratio * 20)
        g = int(250 - ratio * 18)
        b = int(252 - ratio * 15)
        bg_draw.line([(0, y), (width, y)], fill=(r, g, b, 255))
    
    img = Image.alpha_composite(img, bg)

    # 2. Floor vignette & Horizon Line
    horizon_y = 580
    overlay = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    overlay_draw = ImageDraw.Draw(overlay)
    overlay_draw.line([(0, horizon_y), (width, horizon_y)], fill=(210, 215, 225, 120), width=1)
    
    # 3. Ambient Contact Shadow
    cx, cy = 600, 560
    shadow_w = 420
    shadow_h = 90
    shadow_layer = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_layer)
    shadow_draw.ellipse(
        [(cx - shadow_w // 2, cy - shadow_h // 2), (cx + shadow_w // 2, cy + shadow_h // 2)],
        fill=(30, 40, 50, 70)
    )
    # Inner tighter shadow
    shadow_draw.ellipse(
        [(cx - shadow_w // 3, cy - shadow_h // 3), (cx + shadow_w // 3, cy + shadow_h // 3)],
        fill=(15, 20, 30, 110)
    )
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(radius=28))
    img = Image.alpha_composite(img, shadow_layer)

    # 4. Draw Furniture Model Geometry
    base_color = hex_to_rgb(item.get("color_hex", "#A8A6A1"))
    wood_leg_color = (139, 90, 43) if "wood" in item.get("material", "").lower() or "pine" in item.get("material", "").lower() else (45, 45, 45)
    
    draw = ImageDraw.Draw(img)
    cat = item.get("category_slug", "")
    w_cm = item.get("width_cm", 100)
    d_cm = item.get("depth_cm", 80)
    h_cm = item.get("height_cm", 80)

    # Normalization factor for canvas representation
    scale = 1.9

    if cat == "sofas-lounging":
        # Base platform / legs
        draw_iso_box(draw, cx, cy, w_cm * scale * 0.95, d_cm * scale * 0.95, 25, wood_leg_color)
        # Main seat cushion
        draw_iso_box(draw, cx, cy - 25, w_cm * scale, d_cm * scale, 65, base_color)
        # Backrest
        bw = w_cm * scale
        bd = (d_cm * scale) * 0.35
        bh = 110
        # shift back
        draw_iso_box(draw, cx - 20, cy - 90, bw, bd, bh, adjust_color(base_color, 0.95))
        # Armrests
        arm_w = 30
        arm_d = d_cm * scale
        arm_h = 85
        draw_iso_box(draw, cx + int((w_cm * scale) / 2) - 15, cy - 25, arm_w, arm_d, arm_h, adjust_color(base_color, 1.05))
        draw_iso_box(draw, cx - int((w_cm * scale) / 2) + 15, cy - 25, arm_w, arm_d, arm_h, adjust_color(base_color, 0.9))

    elif cat == "dining-chairs":
        # Slender legs
        leg_h = 110
        draw_iso_box(draw, cx + 50, cy, 14, 14, leg_h, wood_leg_color)
        draw_iso_box(draw, cx - 50, cy, 14, 14, leg_h, wood_leg_color)
        draw_iso_box(draw, cx, cy + 30, 14, 14, leg_h, wood_leg_color)
        draw_iso_box(draw, cx, cy - 30, 14, 14, leg_h, wood_leg_color)
        # Seat cushion
        draw_iso_box(draw, cx, cy - leg_h, 140, 130, 30, base_color)
        # Elegant curved backrest
        draw_iso_box(draw, cx - 15, cy - leg_h - 30, 130, 25, 140, adjust_color(base_color, 0.95))

    elif cat == "dining-tables" or cat == "desks":
        # 4 Sturdy corner legs
        table_h = 150
        draw_iso_box(draw, cx + 160, cy, 22, 22, table_h, wood_leg_color)
        draw_iso_box(draw, cx - 160, cy, 22, 22, table_h, wood_leg_color)
        draw_iso_box(draw, cx + 80, cy - 60, 22, 22, table_h, wood_leg_color)
        draw_iso_box(draw, cx - 80, cy + 60, 22, 22, table_h, wood_leg_color)
        # Apron frame
        draw_iso_box(draw, cx, cy - table_h + 20, 340, 170, 20, adjust_color(wood_leg_color, 0.9))
        # Solid Tabletop slab
        draw_iso_box(draw, cx, cy - table_h, 370, 190, 26, base_color)

    elif cat == "beds":
        # Bed base frame
        draw_iso_box(draw, cx, cy, 330, 260, 45, wood_leg_color)
        # Thick luxury mattress
        draw_iso_box(draw, cx, cy - 45, 315, 245, 75, adjust_color(base_color, 1.1))
        # Plush Headboard
        draw_iso_box(draw, cx - 35, cy - 120, 330, 40, 170, base_color)
        # Pillows
        draw_iso_box(draw, cx - 20, cy - 120, 110, 60, 25, (245, 245, 245))
        draw_iso_box(draw, cx + 45, cy - 90, 110, 60, 25, (245, 245, 245))

    elif cat == "coffee-tables":
        # Low table legs
        ct_h = 80
        draw_iso_box(draw, cx + 90, cy, 18, 18, ct_h, wood_leg_color)
        draw_iso_box(draw, cx - 90, cy, 18, 18, ct_h, wood_leg_color)
        draw_iso_box(draw, cx, cy - 45, 18, 18, ct_h, wood_leg_color)
        draw_iso_box(draw, cx, cy + 45, 18, 18, ct_h, wood_leg_color)
        # Main top
        draw_iso_box(draw, cx, cy - ct_h, 260, 180, 28, base_color)

    elif cat == "tv-stands-media":
        # Base feet
        draw_iso_box(draw, cx + 180, cy, 20, 20, 30, wood_leg_color)
        draw_iso_box(draw, cx - 180, cy, 20, 20, 30, wood_leg_color)
        # Low credenza body
        draw_iso_box(draw, cx, cy - 30, 400, 120, 85, base_color)
        # Drawer detail grooves
        draw_iso_box(draw, cx - 70, cy - 40, 120, 10, 60, adjust_color(base_color, 0.85))
        draw_iso_box(draw, cx + 70, cy - 40, 120, 10, 60, adjust_color(base_color, 0.85))

    elif cat == "nightstands":
        # Nightstand legs
        ns_h = 50
        draw_iso_box(draw, cx + 50, cy, 14, 14, ns_h, wood_leg_color)
        draw_iso_box(draw, cx - 50, cy, 14, 14, ns_h, wood_leg_color)
        # Two-tier cabinet
        draw_iso_box(draw, cx, cy - ns_h, 150, 130, 110, base_color)
        # Drawer drawer lines
        draw_iso_box(draw, cx, cy - ns_h - 15, 130, 8, 38, adjust_color(base_color, 0.85))
        draw_iso_box(draw, cx, cy - ns_h - 60, 130, 8, 38, adjust_color(base_color, 0.85))

    else:
        # Accent storage / Wardrobes
        draw_iso_box(draw, cx, cy, 260, 120, 240, base_color)
        # Vertical divider
        draw_iso_box(draw, cx, cy - 20, 10, 10, 200, adjust_color(base_color, 0.85))

    # 5. Add Brand, Product Details & Dimension Typography
    try:
        font_large = ImageFont.truetype("arial.ttf", 34)
        font_medium = ImageFont.truetype("arial.ttf", 20)
        font_mono = ImageFont.truetype("consola.ttf", 16)
        font_small = ImageFont.truetype("arial.ttf", 14)
    except:
        font_large = ImageFont.load_default()
        font_medium = font_large
        font_mono = font_large
        font_small = font_large

    text_draw = ImageDraw.Draw(img)

    # Studio Watermark (Top-Left)
    text_draw.text((60, 50), "SMARTSPACE  |  3D STUDIO COLLECTION", fill=(148, 163, 184), font=font_small)

    # Product Name & Metadata (Bottom-Left)
    text_draw.text((60, 660), item["name"], fill=(15, 23, 42), font=font_large)
    meta_line = f"{item.get('category_name', 'Furniture')}  •  {item.get('material', 'Curated Finish')}"
    text_draw.text((60, 706), meta_line, fill=(100, 116, 139), font=font_medium)

    # Architectural Spec Badge (Bottom-Right)
    badge_w, badge_h = 320, 64
    bx1 = width - badge_w - 60
    by1 = 665
    bx2 = width - 60
    by2 = by1 + badge_h

    badge_overlay = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    b_draw = ImageDraw.Draw(badge_overlay)
    b_draw.rounded_rectangle([bx1, by1, bx2, by2], radius=14, fill=(15, 23, 42, 230))
    img = Image.alpha_composite(img, badge_overlay)

    badge_text_draw = ImageDraw.Draw(img)
    badge_text_draw.text((bx1 + 20, by1 + 14), f"SKU: {item['sku']}  •  1.000 SCALE 🔒", fill=(226, 232, 240), font=font_mono)
    dim_str = f"{int(w_cm)}W × {int(d_cm)}D × {int(h_cm)}H cm  [{item.get('style', 'Modern').capitalize()}]"
    badge_text_draw.text((bx1 + 20, by1 + 36), dim_str, fill=(148, 163, 184), font=font_small)

    # Save as WebP
    rgb_img = img.convert("RGB")
    rgb_img.save(dest_path, "WEBP", quality=90, method=6)
    print(f"Generated {dest_path}")

def main():
    with open(INPUT_JSON, "r", encoding="utf-8") as f:
        items = json.load(f)
    print(f"Generating studio images for {len(items)} items...")
    for item in items:
        generate_image(item)
    print("Done generating all furniture studio images.")

if __name__ == "__main__":
    main()
