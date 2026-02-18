import "./globals.css";
import type { ReactNode } from "react";

export const metadata = {
  title: "Coral Web Host",
  description: "Godot + Next.js host",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
