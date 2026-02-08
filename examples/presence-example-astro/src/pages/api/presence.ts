
import type { APIRoute } from 'astro';

declare global {
	var presenceConnections: Set<ReadableStreamDefaultController> | undefined;
	var lastPresence: any;
}

// POST /presence - receive updates from Neovim plugin
export const POST: APIRoute = async ({ request }) => {
	try {
		const body = await request.json();
		console.log(body);
		
		// Update global presence data
		globalThis.lastPresence = { ...body, received_at: new Date().toISOString() };

		// Broadcast to all SSE clients
		if (globalThis.presenceConnections) {
			const message = `data: ${JSON.stringify(globalThis.lastPresence)}\n\n`;
			for (const controller of globalThis.presenceConnections) {
				try {
					controller.enqueue(new TextEncoder().encode(message));
				} catch (error) {
					// Remove dead connections
					globalThis.presenceConnections.delete(controller);
				}
			}
		}

		return Response.json({ status: body });
	} catch (error) {
		return Response.json({ error: 'Invalid request' }, { status: 400 });
	}
};

// GET /presence - return current presence data
export const GET: APIRoute = async () => {
	return Response.json(globalThis.lastPresence || { status: 'offline' });
};
