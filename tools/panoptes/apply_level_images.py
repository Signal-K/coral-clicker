#!/usr/bin/env python3
"""
Read level_images.json produced by fetch_subjects.py and write the
subject/image references into project/data/starter_levels.json.

Each level gains three new fields:
  source_subject_id  — Zooniverse subject ID
  source_image_path  — res://assets/reef_images/subject_NNN.jpg  (offline)
  source_image_url   — original remote URL (fallback / attribution)

Usage
-----
  python apply_level_images.py
  python apply_level_images.py --dry-run
"""

import argparse
import json
from pathlib import Path

REPO_ROOT         = Path(__file__).parent.parent.parent
LEVEL_IMAGES_PATH = Path(__file__).parent / "level_images.json"
STARTER_LEVELS    = REPO_ROOT / "project" / "data" / "starter_levels.json"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true", help="Print changes without writing")
    args = parser.parse_args()

    if not LEVEL_IMAGES_PATH.exists():
        raise SystemExit(
            f"level_images.json not found — run fetch_subjects.py first.\n"
            f"  Expected: {LEVEL_IMAGES_PATH}"
        )

    with open(LEVEL_IMAGES_PATH) as f:
        level_images: dict = json.load(f)

    with open(STARTER_LEVELS) as f:
        levels_doc: dict = json.load(f)

    changed = 0
    for level in levels_doc["levels"]:
        lid = str(level["id"])
        entry = level_images.get(lid)
        if not entry:
            print(f"  Level {lid}: no entry in level_images.json (skipped)")
            continue

        new_subject_id  = entry.get("subject_id")
        new_image_path  = entry.get("image_path")   # res:// — may be None if not downloaded
        new_image_url   = entry.get("image_url")
        new_depth       = entry.get("depth_m")

        old_subject_id = level.get("source_subject_id")
        old_image_path = level.get("source_image_path")

        if old_subject_id != new_subject_id or old_image_path != new_image_path:
            path_display = new_image_path or "(remote only)"
            print(f"  Level {lid}: subject={new_subject_id}  path={path_display}")
            if not args.dry_run:
                level["source_subject_id"] = new_subject_id
                level["source_image_url"]  = new_image_url
                if new_image_path:
                    level["source_image_path"] = new_image_path
                if new_depth is not None:
                    level["source_depth_m"] = new_depth
            changed += 1
        else:
            print(f"  Level {lid}: unchanged")

    if args.dry_run:
        print(f"\nDry run — {changed} level(s) would be updated.")
        return

    if changed:
        with open(STARTER_LEVELS, "w") as f:
            json.dump(levels_doc, f, indent=2)
        print(f"\nUpdated {changed} level(s) → {STARTER_LEVELS}")
        print("\nRemember to open the Godot editor once so it imports the new images.")
    else:
        print("\nNo changes needed.")


if __name__ == "__main__":
    main()
