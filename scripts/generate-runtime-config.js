#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const templatePath = path.join(root, "config", "runtime.template.json");
const generatedDir = path.join(root, "generated-config");

const template = JSON.parse(fs.readFileSync(templatePath, "utf8"));
const overrides = {
  browser: JSON.parse(
    fs.readFileSync(path.join(root, "templates", "browser.runtime.override.json"), "utf8")
  ),
  desktop: JSON.parse(
    fs.readFileSync(path.join(root, "templates", "desktop.runtime.override.json"), "utf8")
  ),
  mobile: JSON.parse(
    fs.readFileSync(path.join(root, "templates", "mobile.runtime.override.json"), "utf8")
  ),
};

fs.mkdirSync(generatedDir, { recursive: true });

for (const [target, override] of Object.entries(overrides)) {
  const merged = {
    ...template,
    ...override,
    template: template.templates[target],
  };
  fs.writeFileSync(
    path.join(generatedDir, `${target}.runtime.json`),
    JSON.stringify(merged, null, 2)
  );
}

const webEnv = [
  `SUPABASE_URL=${template.supabase.url}`,
  `SUPABASE_ANON_KEY=${template.supabase.anonKey}`,
  `SUPABASE_TABLE=${template.progress.table}`,
  `DEFAULT_PLAYER_ID=${template.progress.defaultPlayerId}`,
].join("\n");

const electronEnv = [
  `WEB_URL=http://127.0.0.1:3000`,
  `SUPABASE_URL=${template.supabase.url}`,
  `SUPABASE_ANON_KEY=${template.supabase.anonKey}`,
  `DEFAULT_PLAYER_ID=${template.progress.defaultPlayerId}`,
].join("\n");

fs.writeFileSync(path.join(root, "web", ".env.local"), `${webEnv}\n`);
fs.writeFileSync(path.join(root, "electron", ".env"), `${electronEnv}\n`);

console.log("Generated runtime templates and env files.");
