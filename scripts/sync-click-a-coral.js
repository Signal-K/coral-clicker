#!/usr/bin/env node

const fs = require("node:fs/promises");
const path = require("node:path");
const { execFile } = require("node:child_process");
const { promisify } = require("node:util");

const execFileAsync = promisify(execFile);

const API_BASE = "https://www.zooniverse.org/api";
const PROJECT_SLUG = "jordan-pierce/click-a-coral";
const ROOT = process.cwd();
const ANOMALIES_DIR = path.join(ROOT, "project/assets/click_a_coral/anomalies");
const DICTIONARY_DIR = path.join(ROOT, "project/assets/click_a_coral/dictionary");
const OUT_JSON = path.join(ROOT, "project/data/click_a_coral_subjects.json");

const args = process.argv.slice(2);
const dryRun = args.includes("--dry-run");
const verbose = !args.includes("--quiet");
const limitArg = args.find((arg) => arg.startsWith("--limit="));
const limit = limitArg ? Number(limitArg.split("=")[1]) : null;

const CANONICAL_NAMES = [
  "Antipathes atlantica",
  "Antipathes furcata",
  "Bebryce Sp.",
  "Ellisellidae",
  "Madracis Sp.",
  "Madrepora Sp.",
  "Muricea pendula",
  "Acanthogorgiidae",
  "Stichopathes",
  "Swiftia exserta",
  "Thesea nivea",
  "Sponge",
];

const TAXONOMY_ALIASES = {
  "antipathes atlantica": ["antipathes", "black coral"],
  "antipathes furcata": ["antipathes", "black coral"],
  "bebryce sp": ["bebryce", "gorgonian"],
  ellisellidae: ["ellisellidae", "sea whip"],
  "madracis sp": ["madracis", "branching coral"],
  "madrepora sp": ["madrepora", "stony coral"],
  "muricea pendula": ["muricea", "sea fan", "gorgonian"],
  acanthogorgiidae: ["gorgonian"],
  stichopathes: ["wire coral", "black coral"],
  "swiftia exserta": ["swiftia", "sea fan"],
  "thesea nivea": ["thesea", "sea fan", "sea plume"],
  sponge: ["sponges"],
};

function sanitizeName(value) {
  return String(value || "")
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function log(message) {
  if (!verbose) return;
  const stamp = new Date().toISOString();
  console.log(`[${stamp}] ${message}`);
}

function chooseCanonicalName(rawName) {
  const needle = sanitizeName(rawName);
  if (!needle) return "Unknown";

  for (const candidate of CANONICAL_NAMES) {
    const normalized = sanitizeName(candidate);
    if (needle.includes(normalized) || normalized.includes(needle)) {
      return candidate;
    }
  }

  for (const candidate of CANONICAL_NAMES) {
    const normalized = sanitizeName(candidate);
    const stem = normalized.split(" ")[0];
    if (stem && needle.includes(stem)) {
      return candidate;
    }
  }

  return "Unknown";
}

function extensionFromLocation(locations) {
  if (!Array.isArray(locations) || locations.length === 0) {
    return "jpg";
  }
  const first = locations[0];
  if (!first || typeof first !== "object") {
    return "jpg";
  }

  const firstUrl = Object.values(first)[0];
  if (typeof firstUrl !== "string" || !firstUrl.length) {
    return "jpg";
  }

  try {
    const pathname = new URL(firstUrl).pathname;
    const ext = path.extname(pathname).replace(".", "").toLowerCase();
    if (ext) return ext;
  } catch {
    return "jpg";
  }

  return "jpg";
}

async function fetchJson(url) {
  const body = await requestText(url, {
    accept: "application/vnd.api+json; version=1",
  });
  try {
    return JSON.parse(body);
  } catch (error) {
    throw new Error(`Invalid JSON from ${url}: ${String(error?.message || error)}`);
  }
}

async function fetchAllPages(url, contextLabel = "request") {
  const items = [];
  let nextUrl = url;
  let page = 0;

  while (nextUrl) {
    page += 1;
    log(`${contextLabel}: fetching page ${page}`);
    const payload = await fetchJson(nextUrl);
    const pageItems = Array.isArray(payload?.[Object.keys(payload)[0]])
      ? payload[Object.keys(payload)[0]]
      : [];
    items.push(...pageItems);
    log(`${contextLabel}: page ${page} returned ${pageItems.length} items (total ${items.length})`);

    const nextHref = payload?.meta?.next_href;
    if (typeof nextHref === "string" && nextHref.length > 0) {
      nextUrl = nextHref.startsWith("http") ? nextHref : `https://www.zooniverse.org${nextHref}`;
    } else {
      nextUrl = null;
    }

    if (limit && items.length >= limit) {
      return items.slice(0, limit);
    }
  }

  return items;
}

async function getProject() {
  const bySlug = `${API_BASE}/projects?slug=${encodeURIComponent(PROJECT_SLUG)}`;
  log(`Resolving project by slug: ${PROJECT_SLUG}`);
  const payload = await fetchJson(bySlug);
  const projects = Array.isArray(payload?.projects) ? payload.projects : [];
  if (projects.length > 0) {
    return projects[0];
  }
  throw new Error(`Unable to find project for slug ${PROJECT_SLUG}`);
}

async function getCollections(projectId) {
  const candidates = [
    `${API_BASE}/collections?project_id=${encodeURIComponent(projectId)}&page_size=100`,
    `${API_BASE}/projects/${projectId}/collections?page_size=100`,
  ];

  for (const url of candidates) {
    log(`Fetching collections from: ${url}`);
    try {
      const payload = await fetchJson(url);
      const list = Array.isArray(payload?.collections) ? payload.collections : [];
      if (list.length > 0) {
        log(`Found ${list.length} collections`);
        return list;
      }
    } catch {
      // Try the next endpoint variant.
      log(`Collection endpoint failed, trying fallback`);
    }
  }

  throw new Error(`No collections found for project_id=${projectId}`);
}

async function getSubjectsForCollection(collectionId) {
  const url = `${API_BASE}/subjects?collection_id=${encodeURIComponent(collectionId)}&page_size=100`;
  return fetchAllPages(url, `collection ${collectionId}`);
}

function acceptedAnswersFor(canonicalName) {
  const normalized = sanitizeName(canonicalName).replace(/\.$/, "");
  const aliases = TAXONOMY_ALIASES[normalized] || [];
  const parts = normalized.split(" ").filter(Boolean);
  const genus = parts[0] || "";
  const family = normalized.endsWith("idae") ? normalized : "";

  const out = new Set([
    canonicalName,
    normalized,
    genus,
    family,
    ...aliases,
  ]);

  return [...out].filter(Boolean);
}

async function downloadTo(filepath, url) {
  try {
    const response = await fetch(url, {
      headers: {
        "user-agent": "coral-click-a-coral-sync/1.0",
      },
      redirect: "follow",
    });
    if (!response.ok) {
      throw new Error(`Image download failed (${response.status}) ${url}`);
    }
    const bytes = Buffer.from(await response.arrayBuffer());
    await fs.writeFile(filepath, bytes);
    return;
  } catch (error) {
    log(`Fetch download failed, retrying via curl: ${url}`);
    await downloadViaCurl(filepath, url, error);
  }
}

async function requestText(url, headers = {}) {
  try {
    const response = await fetch(url, {
      headers: {
        "user-agent": "coral-click-a-coral-sync/1.0",
        ...headers,
      },
      redirect: "follow",
    });

    if (!response.ok) {
      const body = await response.text();
      throw new Error(`Request failed (${response.status}) ${url}\n${body.slice(0, 240)}`);
    }

    return response.text();
  } catch (error) {
    log(`Fetch failed, retrying via curl for: ${url}`);
    return requestTextViaCurl(url, headers, error);
  }
}

async function requestTextViaCurl(url, headers = {}, originalError = null) {
  const args = ["-fsSL", url];
  for (const [key, value] of Object.entries(headers)) {
    args.push("-H", `${key}: ${value}`);
  }
  args.push("-H", "user-agent: coral-click-a-coral-sync/1.0");

  try {
    const { stdout } = await execFileAsync("curl", args, {
      maxBuffer: 20 * 1024 * 1024,
    });
    return stdout;
  } catch (curlError) {
    const original = originalError
      ? `fetch_error=${String(originalError?.message || originalError)}`
      : "fetch_error=none";
    const curlMsg = String(curlError?.stderr || curlError?.message || curlError);
    throw new Error(`Network request failed for ${url}; ${original}; curl_error=${curlMsg.trim()}`);
  }
}

async function downloadViaCurl(filepath, url, originalError = null) {
  const args = [
    "-fsSL",
    "-H",
    "user-agent: coral-click-a-coral-sync/1.0",
    "-o",
    filepath,
    url,
  ];
  try {
    await execFileAsync("curl", args, { maxBuffer: 20 * 1024 * 1024 });
  } catch (curlError) {
    const original = originalError
      ? `fetch_error=${String(originalError?.message || originalError)}`
      : "fetch_error=none";
    const curlMsg = String(curlError?.stderr || curlError?.message || curlError);
    throw new Error(`Image download failed for ${url}; ${original}; curl_error=${curlMsg.trim()}`);
  }
}

async function ensureDirs() {
  await fs.mkdir(ANOMALIES_DIR, { recursive: true });
  await fs.mkdir(DICTIONARY_DIR, { recursive: true });
}

function imageUrlForSubject(subject) {
  const locations = Array.isArray(subject?.locations) ? subject.locations : [];
  for (const location of locations) {
    if (!location || typeof location !== "object") continue;
    for (const key of ["image/jpeg", "image/jpg", "image/png", "image/gif", "image"]) {
      if (typeof location[key] === "string") {
        return location[key];
      }
    }
    const fallback = Object.values(location).find((value) => typeof value === "string");
    if (fallback) return fallback;
  }
  return null;
}

async function main() {
  log(`Starting Click-A-Coral sync dryRun=${dryRun} limit=${limit ?? "none"}`);
  await ensureDirs();
  log(`Ensured output directories`);

  const project = await getProject();
  const projectId = project?.id;
  if (!projectId) {
    throw new Error("Project payload missing id");
  }
  log(`Project resolved: id=${projectId} display_name=${project?.display_name || "unknown"}`);

  const collections = await getCollections(projectId);
  const entries = [];
  const dictionaryIndex = new Map();
  log(`Processing ${collections.length} collections`);

  for (let cIndex = 0; cIndex < collections.length; cIndex += 1) {
    const collection = collections[cIndex];
    const collectionId = collection?.id;
    if (!collectionId) continue;

    const collectionName = String(collection?.display_name || collection?.name || `collection-${collectionId}`);
    const canonicalName = chooseCanonicalName(collectionName);
    log(`Collection ${cIndex + 1}/${collections.length}: ${collectionName} (id=${collectionId}) -> canonical=${canonicalName}`);
    const subjects = await getSubjectsForCollection(collectionId);
    log(`Collection ${collectionId}: ${subjects.length} subjects loaded`);

    for (let sIndex = 0; sIndex < subjects.length; sIndex += 1) {
      const subject = subjects[sIndex];
      const subjectId = String(subject?.id || "").trim();
      if (!subjectId) continue;

      const imageUrl = imageUrlForSubject(subject);
      if (!imageUrl) continue;

      const ext = extensionFromLocation(subject.locations);
      const filename = `${subjectId}.${ext}`;
      const anomalyPath = path.join(ANOMALIES_DIR, filename);
      const anomalyResourcePath = `res://assets/click_a_coral/anomalies/${filename}`;

      if (!dryRun) {
        await downloadTo(anomalyPath, imageUrl);
      }

      if (canonicalName !== "Unknown") {
        const dictionaryFolderName = canonicalName.toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_|_$/g, "");
        const dictionaryFolderPath = path.join(DICTIONARY_DIR, dictionaryFolderName);
        const dictionaryResourcePath = `res://assets/click_a_coral/dictionary/${dictionaryFolderName}/${filename}`;

        if (!dryRun) {
          await fs.mkdir(dictionaryFolderPath, { recursive: true });
          await fs.copyFile(anomalyPath, path.join(dictionaryFolderPath, filename));
        }

        if (!dictionaryIndex.has(canonicalName)) {
          dictionaryIndex.set(canonicalName, {
            canonical_name: canonicalName,
            collection_name: collectionName,
            subject_id: subjectId,
            resource_path: dictionaryResourcePath,
            image_url: imageUrl,
          });
        }
      }

      entries.push({
        project_slug: PROJECT_SLUG,
        collection_id: String(collectionId),
        collection_name: collectionName,
        subject_id: subjectId,
        canonical_name: canonicalName,
        accepted_answers: acceptedAnswersFor(canonicalName),
        image_url: imageUrl,
        resource_path: anomalyResourcePath,
      });

      if (entries.length <= 5 || entries.length % 25 === 0) {
        log(`Progress: saved ${entries.length} entries (latest subject_id=${subjectId}, collection_id=${collectionId})`);
      }

      if (limit && entries.length >= limit) {
        break;
      }
    }

    if (limit && entries.length >= limit) {
      break;
    }
  }

  const payload = {
    generated_at: new Date().toISOString(),
    source: "zooniverse-click-a-coral",
    project_slug: PROJECT_SLUG,
    entries,
    dictionary_representatives: Array.from(dictionaryIndex.values()),
  };

  await fs.writeFile(OUT_JSON, `${JSON.stringify(payload, null, 2)}\n`, "utf8");
  log(`Dictionary representatives: ${dictionaryIndex.size}`);
  console.log(`Saved ${entries.length} subjects to ${path.relative(ROOT, OUT_JSON)}`);
}

main().catch((error) => {
  console.error(error.message || error);
  process.exit(1);
});
