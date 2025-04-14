const express = require('express');
const axios = require('axios');
const fs = require('fs').promises;
const app = express();
const PORT = process.env.PORT || 3000;

// To store results
let results = {
  available: [],
  unavailable: [],
  errors: []
};

// Settings
const CHECK_DELAY = 200; // milliseconds between checks
let isChecking = false;
let startPosition = 0;

app.use(express.json());

// Serve a simple UI
app.get('/', async (req, res) => {
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <title>Roblox Username Checker</title>
      <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        .card { background: #f9f9f9; border-radius: 5px; padding: 15px; margin-bottom: 15px; }
        .available { color: green; }
        .unavailable { color: red; }
        .error { color: orange; }
        .button { background: #4CAF50; color: white; padding: 10px 15px; border: none; border-radius: 5px; cursor: pointer; }
        textarea { width: 100%; height: 150px; margin-bottom: 10px; }
      </style>
    </head>
    <body>
      <h1>Roblox Username Checker</h1>
      <div class="card">
        <h2>Upload Usernames</h2>
        <textarea id="usernamesInput" placeholder="Enter usernames, one per line"></textarea>
        <button class="button" onclick="uploadUsernames()">Upload & Start Checking</button>
      </div>
      
      <div class="card">
        <h2>Status</h2>
        <div id="status">Not checking</div>
        <button class="button" onclick="checkStatus()">Refresh Status</button>
      </div>
      
      <div class="card">
        <h2>Results</h2>
        <div>
          <h3>Available: <span id="availableCount">0</span></h3>
          <div id="availableList"></div>
          <h3>Unavailable: <span id="unavailableCount">0</span></h3>
          <div id="unavailableList"></div>
        </div>
        <button class="button" onclick="downloadResults()">Download Results</button>
      </div>
      
      <script>
        function uploadUsernames() {
          const usernames = document.getElementById('usernamesInput').value.split('\\n').filter(u => u.trim());
          fetch('/check', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ usernames })
          }).then(res => res.json())
            .then(data => {
              alert(data.message);
              checkStatus();
            });
        }
        
        function checkStatus() {
          fetch('/status')
            .then(res => res.json())
            .then(data => {
              document.getElementById('status').innerHTML = data.isChecking ? 
                `Checking: ${data.checked}/${data.total} (${data.percentage}%)` :
                'Not currently checking';

              document.getElementById('availableCount').textContent = data.available.length;
              document.getElementById('unavailableCount').textContent = data.unavailable.length;

              let availableHtml = '';
              data.available.forEach(u => {
                availableHtml += `<div class="available">${u}</div>`;
              });
              document.getElementById('availableList').innerHTML = availableHtml;
            });
        }

        function downloadResults() {
          window.location.href = '/download';
        }

        // Check status every 5 seconds
        setInterval(checkStatus, 5000);
      </script>
    </body>
    </html>
  `;
  res.send(html);
});

// Check status
app.get('/status', (req, res) => {
  res.json({
    isChecking,
    checked: startPosition,
    total: totalUsernames || 0,
    percentage: totalUsernames ? ((startPosition / totalUsernames) * 100).toFixed(2) : 0,
    available: results.available,
    unavailable: results.unavailable
  });
});

// Download results
app.get('/download', async (req, res) => {
  const current_time = new Date().toISOString().replace('T', ' ').substr(0, 19);
  
  let content = `=== Roblox Username Check Results ===\n`;
  content += `Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): ${current_time}\n`;
  content += `Current User's Login: maxz12ok\n\n`;

  content += `=== ✅ AVAILABLE USERNAMES ===\n`;
  if (results.available.length > 0) {
    content += results.available.join('\n') + '\n';
  } else {
    content += 'No available usernames found.\n';
  }
  content += '\n';

  content += `=== ❌ UNAVAILABLE USERNAMES ===\n`;
  if (results.unavailable.length > 0) {
    content += results.unavailable.join('\n') + '\n';
  } else {
    content += 'No unavailable usernames found.\n';
  }

  res.setHeader('Content-Disposition', 'attachment; filename=results.txt');
  res.setHeader('Content-Type', 'text/plain');
  res.send(content);
});

// Initiate checking
let totalUsernames = 0;
let usernamesList = [];

app.post('/check', async (req, res) => {
  if (isChecking) {
    return res.json({ success: false, message: 'Already checking usernames' });
  }

  const usernames = req.body.usernames;
  if (!usernames || !Array.isArray(usernames) || usernames.length === 0) {
    return res.json({ success: false, message: 'No valid usernames provided' });
  }

  // Reset results
  results = {
    available: [],
    unavailable: [],
    errors: []
  };

  usernamesList = usernames;
  totalUsernames = usernames.length;
  startPosition = 0;
  isChecking = true;

  // Start checking in the background
  checkUsernames();

  res.json({
    success: true,
    message: `Started checking ${usernames.length} usernames`
  });
});

// Username checking function
async function checkUsername(username) {
  try {
    const url = `https://auth.roblox.com/v1/usernames/validate?request.username=${username}&request.birthday=1990-01-01`;

    const headers = {
      'User-Agent': `Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/${Math.floor(Math.random() * 30) + 90}.0.0.0 Safari/537.36`,
      'Accept': '*/*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Origin': 'https://www.roblox.com',
      'Referer': 'https://www.roblox.com/'
    };

    const response = await axios.get(url, { headers, timeout: 10000 });

    if (response.status === 200) {
      const message = response.data.message?.toLowerCase() || '';

      if (message.includes('is valid')) {
        console.log(`✅ ${username}: Available`);
        return 'available';
      } else if (message.includes('already in use') || message.includes('not appropriate')) {
        console.log(`❌ ${username}: Unavailable`);
        return 'unavailable';
      } else {
        console.log(`⚠️ ${username}: Unknown status - ${message}`);
        return 'error';
      }
    } else {
      console.log(`⚠️ ${username}: Error status ${response.status}`);
      return 'error';
    }
  } catch (error) {
    console.log(`⚠️ ${username}: Request error - ${error.message}`);
    return 'error';
  }
}

// Process usernames
async function checkUsernames() {
  try {
    while (startPosition < usernamesList.length) {
      const username = usernamesList[startPosition];
      const status = await checkUsername(username);

      if (status === 'available') {
        results.available.push(username);
      } else if (status === 'unavailable') {
        results.unavailable.push(username);
      } else {
        results.errors.push(username);
      }

      startPosition++;
      await new Promise(resolve => setTimeout(resolve, CHECK_DELAY));
    }
  } catch (error) {
    console.error('Error in check process:', error);
  } finally {
    isChecking = false;
  }
}

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});