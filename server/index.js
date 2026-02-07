import express from "express";

const app = express();
app.use(express.json());

let lastPresence = null;

// Receive presence updates
app.post("/presence", (req, res) => {
  lastPresence = {
    ...req.body,
    received_at: new Date().toISOString(),
  };

  console.clear();
  console.log("📡 Presence update received:");
  console.log(JSON.stringify(lastPresence, null, 2));

  res.json({ ok: true });
});

// Fetch latest presence (for UI/testing)
app.get("/presence", (_req, res) => {
  res.json(lastPresence ?? { status: "offline" });
});

// Optional tiny web UI
app.get("/", (_req, res) => {
  res.send(`
<!doctype html>
<pre id="out">Waiting for presence...</pre>
<script>
async function poll() {
  const res = await fetch('/presence');
  const data = await res.json();
  document.getElementById('out').textContent =
    JSON.stringify(data, null, 2);
}
setInterval(poll, 1000);
poll();
</script>
  `);
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Listening on http://localhost:${PORT}`);
});

