/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,

  // Allow cross-origin isolation required for Godot's SharedArrayBuffer (WASM threads).
  // These headers must be present on every response including the Godot iframe content.
  async headers() {
    return [
      {
        // Godot exported game assets — long cache, immutable
        source: "/godot/:path*",
        headers: [
          { key: "Cross-Origin-Opener-Policy",   value: "same-origin" },
          { key: "Cross-Origin-Embedder-Policy",  value: "require-corp" },
          { key: "Cross-Origin-Resource-Policy",  value: "same-site" },
          // Game assets (.pck, .wasm) don't change between sessions
          { key: "Cache-Control", value: "public, max-age=604800, immutable" },
        ],
      },
      {
        // HTML entry point — always revalidate so updates ship immediately
        source: "/godot/index.html",
        headers: [
          { key: "Cross-Origin-Opener-Policy",  value: "same-origin" },
          { key: "Cross-Origin-Embedder-Policy", value: "require-corp" },
          { key: "Cache-Control", value: "no-cache" },
        ],
      },
      {
        // Top-level app pages — same COOP/COEP so the iframe inherits isolation
        source: "/(.*)",
        headers: [
          { key: "Cross-Origin-Opener-Policy",  value: "same-origin" },
          { key: "Cross-Origin-Embedder-Policy", value: "require-corp" },
        ],
      },
    ];
  },
};

module.exports = nextConfig;
