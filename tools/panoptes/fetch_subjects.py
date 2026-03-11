#!/usr/bin/env python3
"""
Fetch subject images from the Click-a-Coral Zooniverse project, download
them into the Godot asset tree, and write manifest files for the game.

Outputs
-------
  subjects_manifest.json                   — every fetched subject record
  level_images.json                        — one representative per level
  ../../project/assets/reef_images/*.jpg   — downloaded images (res:// assets)

Usage
-----
  # Fetch and download 100 subjects (default)
  python fetch_subjects.py

  # Fetch more for better zone coverage
  python fetch_subjects.py --limit 300

  # Authenticated (higher Panoptes rate limits)
  python fetch_subjects.py --username YOU --password SECRET

  # Re-assign levels without re-downloading already-present images
  python fetch_subjects.py --skip-download

  # Use a previously saved manifest (no network calls)
  python fetch_subjects.py --use-cached-manifest
"""

import argparse
import json
import os
import random
import sys
import time
from pathlib import Path
from urllib.parse import urlparse
from urllib.request import urlretrieve

try:
    from panoptes_client import Panoptes, Subject, Workflow
except ImportError:
    sys.exit("panoptes-client not installed. Run: pip install -r requirements.txt")

try:
    import requests
    _HAS_REQUESTS = True
except ImportError:
    _HAS_REQUESTS = False

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
PROJECT_ID  = "21853"
WORKFLOW_ID = "26428"
DEFAULT_LIMIT = 100

TOOLS_DIR   = Path(__file__).parent
REPO_ROOT   = TOOLS_DIR.parent.parent
IMAGES_DIR  = REPO_ROOT / "project" / "assets" / "reef_images"
OUT_DIR     = TOOLS_DIR

MANIFEST_PATH    = OUT_DIR / "subjects_manifest.json"
LEVEL_IMAGES_PATH = OUT_DIR / "level_images.json"

# Depth bucketing: each pair of levels shares a zone
LEVEL_ZONES = [
    {"level": 1,  "zone": "shallow", "depth_min":   0, "depth_max": 100},
    {"level": 2,  "zone": "shallow", "depth_min":   0, "depth_max": 100},
    {"level": 3,  "zone": "mid",     "depth_min": 100, "depth_max": 180},
    {"level": 4,  "zone": "mid",     "depth_min": 100, "depth_max": 180},
    {"level": 5,  "zone": "deep",    "depth_min": 180, "depth_max": 240},
    {"level": 6,  "zone": "deep",    "depth_min": 180, "depth_max": 240},
    {"level": 7,  "zone": "shelf",   "depth_min": 240, "depth_max": 310},
    {"level": 8,  "zone": "shelf",   "depth_min": 240, "depth_max": 310},
    {"level": 9,  "zone": "bed",     "depth_min": 310, "depth_max": 999},
    {"level": 10, "zone": "bed",     "depth_min": 310, "depth_max": 999},
]


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _image_url(subject) -> str | None:
    for loc in subject.raw.get("locations", []):
        for mime, url in loc.items():
            if mime.startswith("image/"):
                return url
    return None


def _depth(metadata: dict) -> float | None:
    for key in ("depth_m", "depth", "Depth_m", "Depth", "depth (m)", "Depth (m)"):
        raw = metadata.get(key)
        if raw is not None:
            try:
                return float(str(raw).replace(",", "."))
            except ValueError:
                pass
    return None


def _ext_for_url(url: str) -> str:
    path = urlparse(url).path
    ext = os.path.splitext(path)[1].lower()
    return ext if ext in (".jpg", ".jpeg", ".png", ".webp") else ".jpg"


def _local_path(subject_id: str, url: str) -> Path:
    return IMAGES_DIR / f"subject_{subject_id}{_ext_for_url(url)}"


def _res_path(subject_id: str, url: str) -> str:
    filename = f"subject_{subject_id}{_ext_for_url(url)}"
    return f"res://assets/reef_images/{filename}"


def _download(url: str, dest: Path, retries: int = 3) -> bool:
    """Download url → dest. Returns True on success."""
    if dest.exists():
        return True  # already present
    dest.parent.mkdir(parents=True, exist_ok=True)
    for attempt in range(1, retries + 1):
        try:
            if _HAS_REQUESTS:
                r = requests.get(url, timeout=20)
                r.raise_for_status()
                dest.write_bytes(r.content)
            else:
                urlretrieve(url, dest)
            return True
        except Exception as exc:
            if attempt < retries:
                time.sleep(2 ** attempt)
            else:
                print(f"    WARNING: download failed for {url}: {exc}")
    return False


# ---------------------------------------------------------------------------
# Fetch
# ---------------------------------------------------------------------------

def fetch_subjects(limit: int) -> list[dict]:
    print(f"Fetching up to {limit} subjects from workflow {WORKFLOW_ID} …")
    subjects = []
    for subject in Subject.where(workflow_id=WORKFLOW_ID):
        url = _image_url(subject)
        if url is None:
            continue
        metadata = subject.raw.get("metadata", {})
        subjects.append({
            "subject_id": str(subject.id),
            "image_url": url,
            "depth_m": _depth(metadata),
            "metadata": metadata,
        })
        if len(subjects) % 50 == 0:
            print(f"  … {len(subjects)} fetched")
        if len(subjects) >= limit:
            break
    print(f"Fetched {len(subjects)} subjects with images.")
    return subjects


# ---------------------------------------------------------------------------
# Download images
# ---------------------------------------------------------------------------

def download_images(subjects: list[dict]) -> int:
    IMAGES_DIR.mkdir(parents=True, exist_ok=True)
    downloaded = 0
    skipped = 0
    failed = 0
    for s in subjects:
        dest = _local_path(s["subject_id"], s["image_url"])
        if dest.exists():
            skipped += 1
            continue
        ok = _download(s["image_url"], dest)
        if ok:
            downloaded += 1
            print(f"  ↓ {dest.name}")
        else:
            failed += 1
    total = downloaded + skipped
    print(f"Images: {downloaded} downloaded, {skipped} already present, {failed} failed  ({total} total)")
    return total


# ---------------------------------------------------------------------------
# Assign level images
# ---------------------------------------------------------------------------

def assign_level_images(subjects: list[dict]) -> dict:
    depth_known   = [s for s in subjects if s["depth_m"] is not None]
    depth_unknown = [s for s in subjects if s["depth_m"] is None]
    rng = random.Random(42)

    level_images: dict = {}
    used_ids: set[str] = set()

    for zone in LEVEL_ZONES:
        level = zone["level"]
        d_min, d_max = zone["depth_min"], zone["depth_max"]

        local_path_str = None

        candidates = [
            s for s in depth_known
            if d_min <= s["depth_m"] < d_max and s["subject_id"] not in used_ids
        ]
        if len(candidates) < 2 and depth_known:
            candidates = [s for s in depth_known if s["subject_id"] not in used_ids]
        if not candidates:
            candidates = [s for s in depth_unknown if s["subject_id"] not in used_ids]

        if not candidates:
            print(f"  WARNING: no subject available for level {level}")
            level_images[str(level)] = None
            continue

        chosen = rng.choice(candidates)
        used_ids.add(chosen["subject_id"])

        local_file = _local_path(chosen["subject_id"], chosen["image_url"])
        if local_file.exists():
            local_path_str = _res_path(chosen["subject_id"], chosen["image_url"])

        level_images[str(level)] = {
            "level":       level,
            "zone":        zone["zone"],
            "subject_id":  chosen["subject_id"],
            "image_url":   chosen["image_url"],   # remote URL (fallback)
            "image_path":  local_path_str,         # res:// path (offline)
            "depth_m":     chosen["depth_m"],
        }
        depth_tag = f"{chosen['depth_m']:.0f} m" if chosen["depth_m"] is not None else "?"
        path_tag  = local_path_str or "(no local file)"
        print(f"  Level {level:2d} [{zone['zone']:7s}]  depth={depth_tag:6s}  {path_tag}")

    return level_images


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description="Fetch Click-a-Coral images from Zooniverse.")
    parser.add_argument("--username",            default=None)
    parser.add_argument("--password",            default=None)
    parser.add_argument("--limit",               type=int, default=DEFAULT_LIMIT,
                        help=f"Max subjects to fetch (default {DEFAULT_LIMIT})")
    parser.add_argument("--skip-download",       action="store_true",
                        help="Skip image download step (assign levels only)")
    parser.add_argument("--use-cached-manifest", action="store_true",
                        help="Use existing subjects_manifest.json, skip Panoptes fetch")
    args = parser.parse_args()

    # Connect
    if args.username and args.password:
        Panoptes.connect(username=args.username, password=args.password)
        print(f"Authenticated as {args.username}")
    else:
        Panoptes.connect()
        print("Connected anonymously")

    # Fetch or load subjects
    if args.use_cached_manifest and MANIFEST_PATH.exists():
        print(f"Loading cached manifest from {MANIFEST_PATH}")
        with open(MANIFEST_PATH) as f:
            subjects = json.load(f)
        print(f"Loaded {len(subjects)} subjects.")
    else:
        subjects = fetch_subjects(args.limit)
        with open(MANIFEST_PATH, "w") as f:
            json.dump(subjects, f, indent=2)
        print(f"Saved manifest → {MANIFEST_PATH}")

    # Download images into the Godot asset tree
    if not args.skip_download:
        print(f"\nDownloading images → {IMAGES_DIR}")
        download_images(subjects)
    else:
        print("Skipping download (--skip-download)")

    # Assign one image per level
    print("\nAssigning level images …")
    level_images = assign_level_images(subjects)
    with open(LEVEL_IMAGES_PATH, "w") as f:
        json.dump(level_images, f, indent=2)
    print(f"Saved → {LEVEL_IMAGES_PATH}")

    assigned = sum(1 for v in level_images.values() if v and v.get("image_path"))
    print(f"\n{assigned}/10 levels have a local image (res:// path).")
    if assigned < 10:
        print("Re-run with a higher --limit to fill remaining levels.")
    print(f"\nNext: run apply_level_images.py to write paths into starter_levels.json")
    print("Then open the Godot editor once so it imports the new images.")


if __name__ == "__main__":
    main()
