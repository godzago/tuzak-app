"""Copy reviewed local rules into the Flutter bundle; no network access."""
import argparse
import json
from pathlib import Path
import shutil


def main():
    app = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=app.parent / "assets")
    parser.add_argument("--check", action="store_true", help="Check for stale bundled copies")
    args = parser.parse_args()
    targets = {
        "rules.json": app / "assets/data/rules.json",
        "usom.json": app / "assets/data/usom.json",
        "test_cases.json": app / "test/fixtures/test_cases.json",
    }
    for name in targets:
        source = args.source / name
        if not source.is_file():
            parser.error(f"Missing authored asset: {source}")
        json.loads(source.read_text(encoding="utf-8"))
    for name, target in targets.items():
        source = args.source / name
        if args.check:
            if not target.is_file() or source.read_bytes() != target.read_bytes():
                parser.error(f"Bundled copy is stale: {target}")
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, target)
    print("Analysis assets are in sync." if args.check else "Analysis assets copied. Rebuild/restart Flutter to load them.")


if __name__ == "__main__":
    main()
