import { NextRequest, NextResponse } from "next/server";
import { broadcast } from "@/app/lib/sse";

export async function POST(req: NextRequest, _res: NextResponse) {
	const body = await req.json();

	broadcast({
		type: "event",
		payload: body,
		at: Date.now(),
	});

	return Response.json({ ok: true });
}
