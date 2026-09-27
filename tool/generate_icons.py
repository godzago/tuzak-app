"""Import supplied Android/iOS icons. Requires Pillow (development only)."""
import argparse
import json
from pathlib import Path
import shutil
from PIL import Image


def main():
    app = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=app.parent / "assets")
    source = parser.parse_args().source.resolve()
    catalog = app / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    ios_source = source / "ios/AppIcon.appiconset"
    android_source = source / "android"
    # Preserve the valid project slots, excluding the source's extra iPhone 76pt slot.
    source_catalog = json.loads((ios_source / "Contents.json").read_text(encoding="utf-8"))
    source_images = {
        (item["idiom"], item["size"], item["scale"]): item["filename"]
        for item in source_catalog["images"]
    }
    destination_catalog = json.loads((catalog / "Contents.json").read_text(encoding="utf-8"))
    ios_images = {}
    for item in destination_catalog["images"]:
        name = source_images[(item["idiom"], item["size"], item["scale"])]
        expected = round(float(item["size"].split("x")[0]) * float(item["scale"][:-1]))
        with Image.open(ios_source / name) as image:
            if image.size != (expected, expected):
                raise ValueError(f"Incorrect iOS dimensions: {name}")
            if image.mode == "RGBA" and image.getchannel("A").getextrema() != (255, 255):
                raise ValueError(f"iOS icon contains transparent pixels: {name}")
            # Remove unused alpha; RGB pixels remain identical.
            ios_images[item["filename"]] = image.convert("RGB")
    android_files = []
    for folder in sorted(android_source.glob("mipmap-*")):
        for path in sorted(folder.iterdir()):
            if path.suffix in (".png", ".xml"):
                if path.suffix == ".png":
                    with Image.open(path) as image:
                        image.verify()
                android_files.append(path)
    background = android_source / "values/ic_launcher_background.xml"
    if not android_files or not background.is_file():
        raise ValueError("Android launcher resources are missing")
    android_files.append(background)
    # All sources have been validated before changing app resources.
    for filename, image in ios_images.items():
        image.save(catalog / filename, format="PNG")
    for path in android_files:
        destination = app / "android/app/src/main/res" / path.relative_to(android_source)
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, destination)
    print(f"Imported {len(ios_images)} iOS icons and {len(android_files)} Android resources.")


if __name__ == "__main__":
    main()
