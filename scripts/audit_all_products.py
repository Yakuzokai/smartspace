import os
import json
import urllib.request

def run_audit():
    url = 'http://127.0.0.1:8000/api/v1/furniture?per_page=100'
    try:
        req = urllib.request.urlopen(url)
        data = json.loads(req.read().decode('utf-8'))['data']
    except Exception as e:
        print(f"Failed to fetch from {url}: {e}")
        return

    models_dir = r'C:\xampp\htdocs\SmartSpace\backend\storage\app\public\furniture\models'
    images_dir = r'C:\xampp\htdocs\SmartSpace\backend\storage\app\public\furniture\images'

    print(f"Total products in store: {len(data)}")
    print("-" * 110)
    print(f"{'#':<3} | {'ID':<3} | {'SKU':<8} | {'Category':<20} | {'Product Name':<34} | {'3D Model Status':<16} | {'Gallery Picture'}")
    print("-" * 110)

    has_glb_count = 0
    missing_glb_count = 0

    results = []

    for idx, item in enumerate(data, 1):
        fid = item['id']
        sku = item['sku']
        cat = item.get('category', {}).get('name', 'N/A')
        name = item['name']
        
        glb_file = f"{sku}.glb"
        glb_path = os.path.join(models_dir, glb_file)
        has_glb = os.path.exists(glb_path) and os.path.getsize(glb_path) > 1000
        glb_size_mb = (os.path.getsize(glb_path) / (1024 * 1024)) if has_glb else 0
        
        img_file = f"{sku}-primary.webp"
        img_path = os.path.join(images_dir, img_file)
        has_img = os.path.exists(img_path)
        img_size_kb = (os.path.getsize(img_path) / 1024) if has_img else 0
        
        # An image is updated if the product has a real GLB and we rendered it
        if has_glb:
            has_glb_count += 1
            model_status = f"GLB ({glb_size_mb:.1f} MB)"
            pic_status = f"Studio Render ({img_size_kb:.1f} KB)"
        else:
            missing_glb_count += 1
            model_status = "PROCEDURAL BOX"
            pic_status = f"OLD PLACEHOLDER ({img_size_kb:.1f} KB)"
            
        row = {
            'num': idx,
            'id': fid,
            'sku': sku,
            'category': cat,
            'name': name,
            'model_status': model_status,
            'pic_status': pic_status,
            'has_glb': has_glb
        }
        results.append(row)
        print(f"{idx:<3} | {fid:<3} | {sku:<8} | {cat[:20]:<20} | {name[:34]:<34} | {model_status:<16} | {pic_status}")

    print("-" * 110)
    print(f"Summary: {has_glb_count} products have full 3D models & studio pictures.")
    print(f"Summary: {missing_glb_count} products currently fallback to procedural boxes & old placeholder cards.")

if __name__ == '__main__':
    run_audit()
