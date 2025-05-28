const http = require('http');
const fs = require('fs');
const path = require('path');

const html = fs.readFileSync(path.join(__dirname, 'gui.html'), 'utf8');

let pendingCommand = null;
let commandResult = null;
let robloxConnected = false;
let lastHeartbeat = null;

// Check for disconnection every 5 seconds
setInterval(() => {
  if (lastHeartbeat && Date.now() - lastHeartbeat > 15000) { // 15 second timeout
    if (robloxConnected) {
      robloxConnected = false;
      console.log('Roblox disconnected (timeout)');
    }
  }
}, 5000);

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  if (req.url === '/') {
    res.writeHead(200, {'Content-Type': 'text/html'});
    res.end(html);
  }
  else if (req.url === '/connect' && req.method === 'POST') {
    robloxConnected = true;
    lastHeartbeat = Date.now();
    // Clear any pending results when reconnecting
    commandResult = null;
    pendingCommand = null;
    console.log('Roblox connected');
    res.writeHead(200);
    res.end('OK');
  }
  else if (req.url === '/poll' && req.method === 'GET') {
    // Update heartbeat on poll
    lastHeartbeat = Date.now();

    if (pendingCommand) {
      const cmd = pendingCommand;
      pendingCommand = null;
      console.log('Sending command to Roblox:', cmd.substring(0, 50) + (cmd.length > 50 ? '...' : ''));
      res.writeHead(200, {'Content-Type': 'text/plain'});
      res.end(cmd);
    } else {
      res.writeHead(200);
      res.end('');
    }
  }
  else if (req.url === '/result' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        // Parse the JSON result from Roblox
        const result = JSON.parse(body);
        commandResult = result;
        console.log('Received result from Roblox:', result.type, result.output ? result.output.substring(0, 100) + '...' : 'no output');
      } catch (e) {
        // Fallback for non-JSON results
        commandResult = { type: 'raw', output: body };
        console.log('Received raw result:', body.substring(0, 100) + (body.length > 100 ? '...' : ''));
      }
      res.writeHead(200);
      res.end('OK');
    });
  }
  else if (req.url === '/send' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      if (!robloxConnected) {
        res.writeHead(400);
        res.end('Roblox not connected');
        return;
      }

      pendingCommand = body;
      commandResult = null;
      console.log('Command queued for Roblox:', body);
      res.writeHead(200);
      res.end('OK');
    });
  }
  else if (req.url === '/getresult' && req.method === 'GET') {
    if (commandResult !== null) {
      const result = commandResult;
      commandResult = null;
      res.writeHead(200, {'Content-Type': 'application/json'});
      res.end(JSON.stringify(result));
    } else {
      res.writeHead(200);
      res.end('');
    }
  }
  else if (req.url === '/status' && req.method === 'GET') {
    res.writeHead(200, {'Content-Type': 'application/json'});
    res.end(JSON.stringify({
      connected: robloxConnected,
      lastHeartbeat: lastHeartbeat
    }));
  }
  else if (req.url === '/disconnect' && req.method === 'POST') {
    robloxConnected = false;
    lastHeartbeat = null;
    console.log('Roblox explicitly disconnected');
    res.writeHead(200);
    res.end('OK');
  }
  else {
    res.writeHead(404);
    res.end('Not Found');
  }
});

server.listen(3000, () => {
  console.log('Server running on http://localhost:3000');
  console.log('Roblox should connect to http://localhost:3000');
});
