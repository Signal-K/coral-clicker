import fs from "fs";
import path from "path";

describe("infra configuration", () => {
  test("docker compose includes core services", () => {
    const compose = fs.readFileSync(path.join(process.cwd(), "docker-compose.yml"), "utf8");
    expect(compose).toContain("web:");
    expect(compose).toContain("bridge:");
    expect(compose).toContain("native-metro:");
    expect(compose).toContain("electron:");
    expect(compose).toContain("sprites:");
  });

  test("makefile has expected top-level targets", () => {
    const makefile = fs.readFileSync(path.join(process.cwd(), "Makefile"), "utf8");
    expect(makefile).toContain("up:");
    expect(makefile).toContain("down:");
    expect(makefile).toContain("up-desktop:");
    expect(makefile).toContain("sprites:");
    expect(makefile).toContain("supabase-schema:");
  });
});
