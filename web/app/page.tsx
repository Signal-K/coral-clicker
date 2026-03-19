"use client";

import { useEffect, useMemo, useRef, useState } from "react";

type GameMessage = {
  action: string;
  [key: string]: unknown;
};

export default function Page() {
  const iframeRef = useRef<HTMLIFrameElement | null>(null);
  const [playerId, setPlayerId] = useState("local-player");
  const [lastEvent, setLastEvent] = useState("No events yet");
  const [supabaseResult, setSupabaseResult] = useState("No Supabase calls yet");

  const levelButtons = useMemo(() => Array.from({ length: 10 }, (_, i) => i + 1), []);

  useEffect(() => {
    const handler = (event: MessageEvent) => {
      if (!event.data || event.data.type !== "godot:event") {
        return;
      }
      setLastEvent(`Received: ${JSON.stringify(event.data.payload)}`);
    };
    window.addEventListener("message", handler);
    return () => window.removeEventListener("message", handler);
  }, []);

  const postToGame = (payload: GameMessage) => {
    iframeRef.current?.contentWindow?.postMessage({ type: "godot:command", payload }, "*");
    setLastEvent(`Sent: ${JSON.stringify(payload)}`);
  };

  const pushProgress = async () => {
    const payload = {
      player_id: playerId,
      current_level: 1,
      completed_levels: [],
      rewards_total: 0,
      metadata: { source: "nextjs" },
    };
    const response = await fetch("/api/progress", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });
    setSupabaseResult(await response.text());
  };

  const pullProgress = async () => {
    const response = await fetch(`/api/progress?playerId=${encodeURIComponent(playerId)}`);
    setSupabaseResult(await response.text());
  };

  return (
    <main>
      <section className="panel">
        <h1>Coral Host Controls</h1>
        <p>Desktop browser template with Godot bridge + Supabase roundtrip.</p>

        <label>
          Player ID
          <input
            value={playerId}
            onChange={(event) => setPlayerId(event.target.value)}
            style={{ width: "100%", marginTop: 4, marginBottom: 8 }}
          />
        </label>

        <div className="controls">
          {levelButtons.map((level) => (
            <button key={level} onClick={() => postToGame({ action: "select_level", level })}>
              L{level}
            </button>
          ))}
        </div>

        <div className="block">
          <button onClick={() => postToGame({ action: "complete_level", reward: 100 })}>Complete Level</button>
          <button onClick={() => postToGame({ action: "load_from_supabase" })}>Load from Supabase</button>
          <button onClick={() => postToGame({ action: "sync_to_supabase" })}>Sync to Supabase</button>
        </div>

        <div className="block">
          <button onClick={pullProgress}>Read Supabase</button>
          <button onClick={pushProgress}>Write Supabase</button>
        </div>

        <h2>Bridge Log</h2>
        <pre>{lastEvent}</pre>

        <h2>Supabase Response</h2>
        <pre>{supabaseResult}</pre>
      </section>

      <section>
        <iframe ref={iframeRef} src="/game/index.html" title="Godot Web Runtime" />
      </section>
    </main>
  );
}
