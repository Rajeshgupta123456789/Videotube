const Redis = require("ioredis");

const redis = new Redis({
  host: process.env.REDIS_HOST,
  port: 6379,
  // password: process.env.REDIS_PASSWORD, // Uncomment if you enable AUTH
  // tls: {}, // Uncomment if TLS is required
});

redis.on("connect", () => console.log("✅  Connected to Redis"));
redis.on("error", (err) => console.error("❌  Redis error:", err));

module.exports = redis;
