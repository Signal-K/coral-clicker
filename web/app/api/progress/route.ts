import { NextRequest, NextResponse } from "next/server";

function env(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing env ${name}`);
  }
  return value;
}

function headers() {
  const key = env("SUPABASE_ANON_KEY");
  return {
    apikey: key,
    Authorization: `Bearer ${key}`,
    "Content-Type": "application/json",
  };
}

export async function GET(request: NextRequest) {
  try {
    const playerId = request.nextUrl.searchParams.get("playerId") || env("DEFAULT_PLAYER_ID");
    const url = `${env("SUPABASE_URL")}/rest/v1/${env("SUPABASE_TABLE")}?player_id=eq.${encodeURIComponent(
      playerId
    )}&select=*`;

    const res = await fetch(url, { headers: headers(), cache: "no-store" });
    const body = await res.text();
    return new NextResponse(body, { status: res.status, headers: { "Content-Type": "application/json" } });
  } catch (error) {
    return NextResponse.json({ error: (error as Error).message }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    const payload = await request.json();
    const url = `${env("SUPABASE_URL")}/rest/v1/${env("SUPABASE_TABLE")}?on_conflict=player_id`;

    const res = await fetch(url, {
      method: "POST",
      headers: {
        ...headers(),
        Prefer: "return=representation,resolution=merge-duplicates",
      },
      body: JSON.stringify([payload]),
    });

    const body = await res.text();
    return new NextResponse(body, { status: res.status, headers: { "Content-Type": "application/json" } });
  } catch (error) {
    return NextResponse.json({ error: (error as Error).message }, { status: 500 });
  }
}
