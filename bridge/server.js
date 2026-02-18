#!/usr/bin/env node

const http = require("http");

const port = Number(process.env.BRIDGE_PORT || 8787);
const supabaseUrl = process.env.SUPABASE_URL || "http://host.docker.internal:54321";
const supabaseAnonKey =
  process.env.SUPABASE_ANON_KEY || "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH";
const table = process.env.SUPABASE_TABLE || "player_progress";

function sendJson(res, code, payload) {
  const body = JSON.stringify(payload);
  res.writeHead(code, {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
  });
  res.end(body);
}

async function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = "";
    req.on("data", (chunk) => {
      data += chunk;
    });
    req.on("end", () => resolve(data));
    req.on("error", reject);
  });
}

const server = http.createServer(async (req, res) => {
  if (req.method === "OPTIONS") {
    sendJson(res, 200, { ok: true });
    return;
  }

  if (req.url === "/health") {
    sendJson(res, 200, {
      ok: true,
      supabaseUrl,
      table,
      timestamp: new Date().toISOString(),
    });
    return;
  }

  if (req.url && req.url.startsWith("/progress") && req.method === "GET") {
    const query = new URL(req.url, "http://localhost").searchParams;
    const playerId = query.get("playerId") || "local-player";
    const url = `${supabaseUrl}/rest/v1/${table}?player_id=eq.${encodeURIComponent(
      playerId
    )}&select=*`;

    const response = await fetch(url, {
      headers: {
        apikey: supabaseAnonKey,
        Authorization: `Bearer ${supabaseAnonKey}`,
      },
    });

    sendJson(res, response.status, await response.json());
    return;
  }

  if (req.url === "/progress" && req.method === "POST") {
    const body = await readBody(req);
    const payload = JSON.parse(body || "{}");
    const url = `${supabaseUrl}/rest/v1/${table}?on_conflict=player_id`;

    const response = await fetch(url, {
      method: "POST",
      headers: {
        apikey: supabaseAnonKey,
        Authorization: `Bearer ${supabaseAnonKey}`,
        "Content-Type": "application/json",
        Prefer: "return=representation,resolution=merge-duplicates",
      },
      body: JSON.stringify([payload]),
    });

    sendJson(res, response.status, await response.json());
    return;
  }

  sendJson(res, 404, { error: "not found" });
});

server.listen(port, () => {
  console.log(`Bridge listening on http://127.0.0.1:${port}`);
});
