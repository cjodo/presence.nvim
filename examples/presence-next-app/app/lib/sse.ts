type Client = WritableStreamDefaultWriter<Uint8Array>;

const clients = new Set<Client>();

export const addClient = (writer: Client) => {
	clients.add(writer);
}

export const removeClient = (writer: Client) => {
	clients.delete(writer);
}

export const broadcast = (data: unknown) => {
	const payload = `data: ${ JSON.stringify(data) }\n\n`;
	const encoded = new TextEncoder().encode(payload);

	for (const client of clients) {
		client.write(encoded).catch(() => {
			clients.delete(client);
		})
	}
}



