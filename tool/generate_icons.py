"""Render Tuzak's geometric shield mark. Requires Pillow (development only)."""
import json
from pathlib import Path
from PIL import Image, ImageDraw

root = Path(__file__).resolve().parents[1]
image = Image.new("RGB", (1024, 1024), "#0A2540")
draw = ImageDraw.Draw(image)
shield = [(512, 200), (746, 295), (730, 534), (691, 635),
          (617, 720), (512, 791), (407, 720), (333, 635),
          (294, 534), (278, 295), (512, 200)]
draw.line(shield, fill="#F8FAFC", width=34, joint="curve")
draw.line([(400, 490), (484, 574), (633, 412)], fill="#B9DACE", width=39, joint="curve")

def save(path, size):
    destination = root / path
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.resize((size, size), Image.Resampling.LANCZOS).save(destination)

catalog = root / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
for item in json.loads((catalog / "Contents.json").read_text())["images"]:
    size = round(float(item["size"].split("x")[0]) * float(item["scale"].rstrip("x")))
    save(catalog.relative_to(root) / item["filename"], size)
for density, size in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
    save(f"android/app/src/main/res/mipmap-{density}/ic_launcher.png", size)
for size in [192, 512]:
    save(f"web/icons/Icon-{size}.png", size)
    save(f"web/icons/Icon-maskable-{size}.png", size)
save("web/favicon.png", 32)
print("Tuzak icons generated for iOS, Android and web.")
