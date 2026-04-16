"use client";

import { useEffect, useRef } from "react";

export default function Page() {
  const iframeRef = useRef<HTMLIFrameElement | null>(null);

  useEffect(() => {
    const handler = (event: MessageEvent) => {
      if (!event.data || event.data.type !== "godot:event") {
        return;
      }
      // console.log("Godot Event:", event.data.payload);
    };
    window.addEventListener("message", handler);
    return () => window.removeEventListener("message", handler);
  }, []);

  return (
    <main>
      <iframe ref={iframeRef} src="/game/index.html" title="Coral Clicker" allow="autoplay; fullscreen; wake-lock" />
    </main>
  );
}
