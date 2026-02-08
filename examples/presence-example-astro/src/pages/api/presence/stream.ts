import type { APIRoute } from 'astro';

declare global {
	var presenceConnections: Set<ReadableStreamDefaultController> | undefined;
	var lastPresence: any;
}

export const GET: APIRoute = async ({ request }) => {
	const stream = new ReadableStream({
		start(controller) {
			// Initialize global connections set if needed
			if (!globalThis.presenceConnections) {
				globalThis.presenceConnections = new Set();
			}
			
			// Add this connection to the global set
			globalThis.presenceConnections.add(controller);
			
			// Send current data if available
			if (globalThis.lastPresence) {
				const message = `data: ${JSON.stringify(globalThis.lastPresence)}\n\n`;
				controller.enqueue(new TextEncoder().encode(message));
			}

			const heartbeat = setInterval(() => {
				try {
					controller.enqueue(new TextEncoder().encode(': heartbeat\n\n'));
				} catch (error) {
					clearInterval(heartbeat);
					globalThis.presenceConnections?.delete(controller);
				}
			}, 1000);
			
			// Cleanup on connection close
			request.signal.addEventListener('abort', () => {
				clearInterval(heartbeat);
				globalThis.presenceConnections?.delete(controller);
			});
		}
	});

	return new Response(stream, {
		headers: {
			'Content-Type': 'text/event-stream',
			'Cache-Control': 'no-cache',
			'Connection': 'keep-alive',
			'Access-Control-Allow-Origin': '*',
			'Access-Control-Allow-Headers': 'Content-Type',
		},
	});
};
