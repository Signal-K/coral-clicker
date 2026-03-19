import fs from "fs";
import path from "path";

describe("starter puzzle content", () => {
  const levelsPath = path.join(process.cwd(), "project/data/starter_levels.json");
  const speciesPath = path.join(process.cwd(), "project/data/species_reference.json");

  const levelsDoc = JSON.parse(fs.readFileSync(levelsPath, "utf8"));
  const speciesDoc = JSON.parse(fs.readFileSync(speciesPath, "utf8"));

  test("contains exactly 10 levels", () => {
    expect(Array.isArray(levelsDoc.levels)).toBe(true);
    expect(levelsDoc.levels).toHaveLength(10);
  });

  test("every level has required progression fields", () => {
    for (const level of levelsDoc.levels) {
      expect(typeof level.id).toBe("number");
      expect(level.id).toBeGreaterThanOrEqual(1);
      expect(level.id).toBeLessThanOrEqual(10);

      expect(typeof level.target_coral).toBe("string");
      expect(typeof level.starting_nutrients).toBe("number");
      expect(level.starting_nutrients).toBeGreaterThan(0);
      expect(typeof level.reward_coins).toBe("number");
      expect(level.reward_coins).toBeGreaterThan(0);
      expect(level.starting_fishfood).toBeUndefined();
      expect(level.reward_fishfood).toBeUndefined();

      expect(Array.isArray(level.positive_fish)).toBe(true);
      expect(Array.isArray(level.negative_fish)).toBe(true);
      expect(typeof level.starting_fish).toBe("object");
    }
  });

  test("economy and resource-bar defaults match the nutrients/coins model", () => {
    expect(levelsDoc.economy?.completion_bonus_currency).toBe("coins");

    const resourceBarPath = path.join(
      process.cwd(),
      "project/scenes/layout/BottomResourceBar.tscn",
    );
    const resourceBar = fs.readFileSync(resourceBarPath, "utf8");

    expect(resourceBar).toContain('text = "Nutrients: 0"');
    expect(resourceBar).toContain('text = "Coins: 0"');
    expect(resourceBar).toContain('text = "Turn: 0/0"');
    expect(resourceBar).toContain('text = "Reef: 0%"');
  });

  test("species reference has 12 corals and 5 fish species", () => {
    expect(speciesDoc.corals).toHaveLength(12);
    expect(speciesDoc.fish_species).toHaveLength(5);
  });
});
