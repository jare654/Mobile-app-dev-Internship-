const http = require('http');
const url = require('url');

// CORS proxy server for NewsAPI
const targetHost = 'newsapi.org';
const port = 8000;

// Request handler
const server = http.createServer((req, res) => {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Api-Key');
  res.setHeader('Access-Control-Allow-Credentials', 'true');

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // Proxy request to NewsAPI
  const targetUrl = `https://${targetHost}${req.url}`;
  const parsedUrl = url.parse(targetUrl);
  
  const options = {
    hostname: parsedUrl.hostname,
    port: parsedUrl.port,
    path: parsedUrl.path,
    method: req.method,
    headers: {
      ...req.headers,
      // Remove host header to avoid conflicts
      host: targetHost,
      // Add CORS headers to allow browser
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Api-Key',
    },
    // Add query parameters
    search: parsedUrl.search,
  };

  const proxyReq = http.request(options, (proxyRes) => {
    // Add CORS headers to response
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Api-Key');
    res.setHeader('Access-Control-Allow-Credentials', 'true');

    // Forward response
    res.writeHead(proxyRes.statusCode, proxyRes.headers);
    proxyRes.pipe(res);
  });

  // Forward request body
  req.pipe(proxyReq);
});

// Start server
server.listen(port, () => {
  console.log(`🚀 NewsAPI CORS Proxy Server running on port ${port}`);
  console.log(`📡 Proxying requests to: https://${targetHost}`);
  console.log(`📱 Access your Flutter app at: http://localhost:${port}`);
  console.log(`🔑 Your API key will be proxied securely`);
});

// Handle graceful shutdown
process.on('SIGINT', () => {
  console.log('\n🛑 Shutting down proxy server...');
  server.close(() => {
    console.log('✅ Proxy server stopped');
    process.exit(0);
  });
});

process.on('SIGTERM', () => {
  console.log('\n🛑 Shutting down proxy server...');
  server.close(() => {
    console.log('✅ Proxy server stopped');
    process.exit(0);
  });
});
