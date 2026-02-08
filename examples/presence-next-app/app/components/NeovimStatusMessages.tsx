"use client";
import { useEffect, useState } from "react";

export const NeovimStatusMessages = () => {
  const [events, setEvents] = useState<any[]>([]);

  useEffect(() => {
    const es = new EventSource("/api/events/presence/");

    es.onmessage = (e) => {
			console.log(e.data)
      setEvents((prev) => [...prev, JSON.parse(e.data)]);
    };

    return () => es.close();
  }, []);

  return (
    <pre>{JSON.stringify(events, null, 2)}</pre>
  );
}

