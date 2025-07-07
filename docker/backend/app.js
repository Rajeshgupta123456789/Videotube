const express = require('express');
const app = express();
const PORT = 3000;

const redis = require("./redisClient");


app.get("/", (req, res) => {
  res.send("Welcome to Videotube 🎥 ");
});

app.get("/cache-example", async (req, res) => {
  try {
    const cached = await redis.get("demo-key");
    if (cached) {
      return res.json({ from: "cache", data: JSON.parse(cached) });
    }

    const data = { message: "Fresh data from backend" };
    await redis.set("demo-key", JSON.stringify(data), "EX", 3600); // 1hr
    res.json({ from: "origin", data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`🚀  Server running on port ${PORT}`);
});

