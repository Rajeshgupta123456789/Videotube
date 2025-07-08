const express = require('express');
const app = express();
const PORT = 3000;

const AWS = require('aws-sdk');
const { Pool } = require('pg');
const redis = require('./redisClient');
const metricsHandler = require('./metrics');
const client = require('prom-client');
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics();

app.use(express.json());

// Prometheus metrics
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

// AWS Secrets Manager
const secretsManager = new AWS.SecretsManager({ region: 'us-east-1' });
let pgPool;

async function initPostgresConnection() {
  try {
    const secret = await secretsManager.getSecretValue({ SecretId: 'videotube/rds/postgres' }).promise();
    const creds = JSON.parse(secret.SecretString);

    pgPool = new Pool({
      user: creds.username,
      host: creds.host,
      database: creds.dbname,
      password: creds.password,
      port: creds.port,
    });

    console.log('✅ Connected to PostgreSQL via Secrets Manager');
  } catch (err) {
    console.error('❌ DB Secret retrieval failed:', err);
    process.exit(1);
  }
}

// Routes
app.get("/", (req, res) => {
  res.send("Welcome to Videotube 🎥");
});

app.get("/cache-example", async (req, res) => {
  try {
    const cached = await redis.get("demo-key");
    if (cached) {
      return res.json({ from: "cache", data: JSON.parse(cached) });
    }

    const data = { message: "Fresh data from backend" };
    await redis.set("demo-key", JSON.stringify(data), "EX", 3600); // 1 hour
    res.json({ from: "origin", data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Save metadata route
app.post('/api/save-metadata', async (req, res) => {
  const { filename, s3_url } = req.body;

  try {
    await pgPool.query(
      'INSERT INTO videos (filename, s3_url, uploaded_at) VALUES ($1, $2, NOW())',
      [filename, s3_url]
    );
    res.send("✅ Metadata saved successfully");
  } catch (err) {
    console.error('❌ Failed to save metadata:', err);
    res.status(500).send("Error saving metadata");
  }
});

// Init DB then start server
initPostgresConnection().then(() => {
  app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
  });
});
