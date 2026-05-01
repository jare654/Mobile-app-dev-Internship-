# Chrome Security Fix for PulseNews

## 🚨 Problem
Chrome blocks HTTP requests from `file://` URLs for security reasons. This prevents the Flutter app from making API calls to NewsAPI.org.

## ✅ Solutions

### Option 1: CORS Proxy Server (Recommended)
**Use the Node.js proxy server I created:**

1. **Start the proxy server:**
   ```bash
   cd "/Users/yared/Downloads/News App/web"
   node proxy-server.js
   ```

2. **Update your Flutter app to use localhost:**
   - Open `lib/services/news_api_service.dart`
   - Change line 56: `static const String _baseUrl = 'localhost:8000';`

3. **Run your Flutter app:**
   ```bash
   flutter run -d chrome
   ```

**Benefits:**
- ✅ Bypasses Chrome security restrictions
- ✅ Handles CORS properly
- ✅ Secure proxy to NewsAPI
- ✅ Works with existing API key

### Option 2: Use Firefox
Firefox doesn't block `file://` HTTP requests like Chrome does.

1. Run your Flutter app in Firefox:
   ```bash
   flutter run -d firefox
   ```

### Option 3: Disable Chrome Security (Temporary)
**Not recommended for long-term use:**

```bash
chrome --disable-web-security --user-data-dir=/tmp/chrome_dev --allow-file-access-from-files
```

### Option 4: Use VS Code Live Server
1. Install "Live Server" extension in VS Code
2. Open your project in VS Code
3. Right-click `index.html` in `web/` folder
4. Select "Open with Live Server"

## 🔧 Quick Fix Steps

1. **Start proxy server:**
   ```bash
   cd "/Users/yared/Downloads/News App/web"
   node proxy-server.js
   ```
   You should see: `🚀 NewsAPI CORS Proxy Server running on port 8000`

2. **Update Flutter app:**
   Edit `lib/services/news_api_service.dart` line 56:
   ```dart
   static const String _baseUrl = 'localhost:8000';
   ```

3. **Run Flutter app:**
   ```bash
   flutter run -d chrome
   ```

4. **Allow connection in Chrome:**
   When Chrome shows security warning, click "Advanced" → "Proceed to localhost"

## 🎯 Why This Works

- The proxy server runs on `localhost:8000`
- Chrome allows HTTP requests to `localhost`
- The proxy server forwards requests to `newsapi.org`
- CORS headers are properly handled
- Your API key remains secure

## 📁 Files Created

- `web/proxy-server.js` - Node.js CORS proxy server
- `web/dev-server.html` - Development server interface
- `web/README.md` - This documentation

## 🔒 Security Notes

- The proxy server only runs locally for development
- API keys are not exposed to external sites
- CORS is properly configured
- All requests are logged locally

## 🚀 Production Deployment

For production deployment:
- Use HTTPS URLs
- Deploy to a proper web server
- Configure CORS on your production server
- Never use the proxy server in production

---

**Your API key `ccfeade60e6a6450a8f62a1925c1b2435` is correctly configured.**
**The issue is purely Chrome's security restrictions.**
