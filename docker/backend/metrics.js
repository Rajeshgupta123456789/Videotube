const client = require('prom-client');
const register = new client.Registry();

// Collect default system metrics (CPU, memory, etc.)
client.collectDefaultMetrics({ register });

module.exports = async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
};
