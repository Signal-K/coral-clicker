import json
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

from PIL import Image


class SpriteGenerationTests(unittest.TestCase):
    def test_generation_outputs_64px_transparent_assets(self):
        with tempfile.TemporaryDirectory() as tmp:
            out_dir = Path(tmp) / "out"
            cmd = [
                "python3",
                "tools/sprites/generate_sprites.py",
                "--out-dir",
                str(out_dir),
                "--frames",
                "6",
                "--sheet-cols",
                "3",
            ]
            subprocess.run(cmd, check=True)

            species_index = out_dir / "meta" / "species_index.json"
            self.assertTrue(species_index.exists())

            data = json.loads(species_index.read_text(encoding="utf-8"))
            self.assertGreaterEqual(data["sprite_width"], 64)
            self.assertGreaterEqual(data["sprite_height"], 64)
            self.assertEqual(len(data["species"]), 17)

            first = data["species"][0]["slug"]
            frame_path = out_dir / "sprites" / f"{first}_frame_00.png"
            self.assertTrue(frame_path.exists())

            image = Image.open(frame_path)
            self.assertEqual(image.size, (64, 64))

            alpha = image.getchannel("A")
            self.assertLess(alpha.getextrema()[0], 255)


if __name__ == "__main__":
    unittest.main()
