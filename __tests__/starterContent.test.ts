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
      expect(typeof level.starting_fishfood).toBe("number");
      expect(typeof level.reward_fishfood).toBe("number");
      expect(level.reward_fishfood).toBeGreaterThan(0);

      expect(Array.isArray(level.positive_fish)).toBe(true);
      expect(Array.isArray(level.negative_fish)).toBe(true);
      expect(typeof level.starting_fish).toBe("object");
    }
  });

  test("species reference has 12 corals and 5 fish species", () => {
    expect(speciesDoc.corals).toHaveLength(12);
    expect(speciesDoc.fish_species).toHaveLength(5);
  });
});
