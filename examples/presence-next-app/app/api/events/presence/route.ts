import { addClient } from "@/app/lib/sse";
import { NextRequest, NextResponse } from "next/server";

declare global {
	var presenceConnections: Set<ReadableStreamDefaultController> | undefined;
	var lastPresence: any;
}

export async function GET(res:NextResponse, req:NextRequest) {
	const stream = new TransformStream();
	const writer = stream.writable.getWriter();

	addClient(writer);

	writer.write(
		new TextEncoder().encode("event: connected\ndata: ok\n\n")
	);

	return new Response(stream.readable, {
		headers: {
			"Content-Type": "text/event-stream",
			"Cache-Control": "no-cache",
			"Connection": "keep-alive",
		},
	});
}
