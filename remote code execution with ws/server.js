const http = require('http');
const WebSocket = require('ws');
const fs = require('fs');
const path = require('path');

// Serve the HTML GUI
const html = fs.readFileSync(path.join(__dirname, 'gui.html'), 'utf8');
const server = http.createServer((req, res) => {
  if (req.url === '/') {
    res.writeHead(200, {'Content-Type': 'text/html'});
    res.end(html);
  } else {
    res.writeHead(404);
    res.end();
  }
});

let robloxSocket = null;
let guiSocket = null;

const wss = new WebSocket.Server({ server });

wss.on('connection', (ws, req) => {
  const isRoblox = req.url.includes('role=roblox');
  if (isRoblox) {
    robloxSocket = ws;
    if (guiSocket) guiSocket.send(JSON.stringify({type: "status", msg: "Roblox connected!"}));
    ws.on('message', msg => {
      if (guiSocket) {
        let m = msg.toString();
        try { m = JSON.parse(m); } catch {}
        guiSocket.send(JSON.stringify({type: "roblox", msg: m}));
      }
    });
    ws.on('close', () => {
      robloxSocket = null;
      if (guiSocket) guiSocket.send(JSON.stringify({type: "status", msg: "Roblox disconnected!"}));
    });
  } else {
    guiSocket = ws;
    guiSocket.send(JSON.stringify({type: "status", msg: "Web GUI connected!"}));
    ws.on('message', msg => {
      if (robloxSocket && robloxSocket.readyState === WebSocket.OPEN) {
        robloxSocket.send(msg);
        guiSocket.send(JSON.stringify({type: "status", msg: "Command sent to Roblox!"}));
      } else {
        guiSocket.send(JSON.stringify({type: "status", msg: "Roblox not connected!"}));
      }
    });
    ws.on('close', () => {
      guiSocket = null;
    });
  }
});

server.listen(3000, () => {
  console.log('Go to http://localhost:3000 in your browser.');
  console.log('Roblox should connect to ws://localhost:3000/?role=roblox');
});
