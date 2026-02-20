import os
from PIL import Image

def generate_mipmaps(src_path, output_base):
    if not os.path.exists(src_path):
        print(f"Error: {src_path} not found")
        return

    img = Image.open(src_path)
    
    # Android mipmap sizes for icons (assuming square/contain fit)
    # mdpi: 48x48
    # hdpi: 72x72
    # xhdpi: 96x96
    # xxhdpi: 144x144
    # xxxhdpi: 192x192
    
    sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }

    for folder, size in sizes.items():
        folder_path = os.path.join(output_base, folder)
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)
        
        # Keep aspect ratio and fit into the square
        thumb = img.copy()
        thumb.thumbnail((size, size), Image.Resampling.LANCZOS)
        
        # If not square, we could center it on a transparent background, 
        # but usually logos are okay if they are fit.
        # However, for launcher icons they SHOULD be square.
        # Let's create a square transparent image and paste the logo in center.
        
        new_img = Image.new("RGBA", (size, size), (255, 255, 255, 0))
        text_pos = ((size - thumb.width) // 2, (size - thumb.height) // 2)
        new_img.paste(thumb, text_pos)
        
        new_img.save(os.path.join(folder_path, 'ic_launcher.png'))
        new_img.save(os.path.join(folder_path, 'vertical.png'))
        print(f"Generated {folder}/vertical.png and ic_launcher.png")

if __name__ == "__main__":
    generate_mipmaps('assets/images/vertical.png', 'android/app/src/main/res')
