import express from "express";

const app = express();
app.use(express.json());

let lastPresence = null;
let totalPostsReceived = 0;

// Receive presence updates
app.post("/presence", (req, res) => {
  totalPostsReceived++;
  lastPresence = {
    ...req.body,
    received_at: new Date().toISOString(),
  };

  res.json({ ok: true });
});

// Fetch latest presence (for UI/testing)
app.get("/presence", (_req, res) => {
  res.json(lastPresence ?? { status: "offline" });
});

// Fetch statistics
app.get("/stats", (_req, res) => {
  res.json({ totalPostsReceived });
});

// Optional tiny web UI
app.get("/", (_req, res) => {
  res.send(`
<!doctype html>
<html>
<head>
  <title>Presence Monitor</title>
  <style>
    body { font-family: monospace; margin: 20px; background: #1e1e1e; color: #fff; }
    h1 { color: #61dafb; }
    .stats { background: #2d2d2d; padding: 10px; border-radius: 5px; margin-bottom: 20px; }
    .stats span { margin-right: 20px; }
    #out { background: #2d2d2d; padding: 15px; border-radius: 5px; white-space: pre-wrap; }
  </style>
</head>
<body>
  <h1>🔍 Presence Monitor</h1>
  <div class="stats">
    <span>📊 Total Posts: <strong id="postCount">0</strong></span>
    <span>🕐 Last Update: <strong id="lastUpdate">Never</strong></span>
    <span>📡 Status: <strong id="status">Waiting...</strong></span>
  </div>
  <pre id="out">Waiting for presence...</pre>
  <script>
    let lastPostCount = 0;
    
    async function poll() {
      const [presenceRes, statsRes] = await Promise.all([
        fetch('/presence'),
        fetch('/stats')
      ]);
      
      const data = await presenceRes.json();
      const stats = await statsRes.json();
      
      // Update presence display
      document.getElementById('out').textContent = JSON.stringify(data, null, 2);
      document.getElementById('lastUpdate').textContent = data.received_at ? 
        new Date(data.received_at).toLocaleTimeString() : 'Never';
      
      // Update post count from server
      const currentPostCount = stats.totalPostsReceived || 0;
      document.getElementById('postCount').textContent = currentPostCount;
      
      // Determine status
      let status = data.status || 'Unknown';
      if (data.file) status += \` | File: \${data.file}\`;
      if (data.project) status += \` | Project: \${data.project}\`;
      document.getElementById('status').textContent = status;
      
      // Track new posts visually
      if (currentPostCount > lastPostCount) {
        document.getElementById('postCount').style.color = '#61dafb';
        setTimeout(() => {
          document.getElementById('postCount').style.color = '#fff';
        }, 300);
      }
      lastPostCount = currentPostCount;
    }
    
    setInterval(poll, 1000);
    poll();
  </script>
</body>
</html>
  `);
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Listening on http://localhost:${PORT}`);
});

