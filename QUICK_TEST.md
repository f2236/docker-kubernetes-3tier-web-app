# 🧪 QUICK TESTING GUIDE - What Works Right Now

## ✅ Current Setup (Working)

You already have running:
- ✅ **Backend**: http://localhost:8080 (Node.js Express)
- ✅ **Frontend**: http://localhost:3000 (React)

---

## 🔬 TEST 1: Backend API is Working

### Test URL
```
http://localhost:8080/
```

### Test Commands

**Windows PowerShell:**
```powershell
# Check if backend is responding
Invoke-WebRequest http://localhost:8080/ -UseBasicParsing

# Expected: Status code 200 or similar response
```

**Using curl (if available):**
```bash
curl http://localhost:8080/
```

### What to Look For
- ✅ Response code: 200 OK
- ✅ No "Connection refused" error
- ✅ Backend is listening on port 8080

---

## 🔬 TEST 2: Frontend is Loading

### Test URL
```
http://localhost:3000
```

### Steps
1. Open **http://localhost:3000** in your browser
2. Look for the TodoList application to display
3. Check for errors in the browser console (F12)

### What to Look For
- ✅ Page loads (not blank)
- ✅ "TodoList" title appears
- ✅ Input field for adding todos visible
- ✅ No RED errors in console

---

## 🔬 TEST 3: Create a Todo (Full Application Test)

### Using Browser UI (Easiest)
1. Open http://localhost:3000
2. Type in the input field: **"Test item"**
3. Click **"Add"** button
4. Verify the todo appears in the list

### Using API Command

**Windows PowerShell:**
```powershell
$body = @{todo="Test Todo from API"} | ConvertTo-Json
Invoke-WebRequest -Uri http://localhost:8080/create `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body

# Should see response with the created todo
```

### What to Look For
- ✅ New todo appears in the list
- ✅ No error messages
- ✅ Todo ID is generated

---

## 🔬 TEST 4: Get All Todos (API Test)

**Windows PowerShell:**
```powershell
$response = Invoke-WebRequest http://localhost:8080/ -UseBasicParsing
$response.Content

# Shows all todos in JSON format
```

### What to Look For
- ✅ Returns JSON array
- ✅ Contains todo items you created
- ✅ Each has: id, todo, created_at

---

## 🔬 TEST 5: Edit a Todo

**Browser UI:**
1. Open http://localhost:3000
2. Find a todo item
3. Click "Edit" button
4. Change the text
5. Verify change is saved

### What to Look For
- ✅ Edit button works
- ✅ Todo text updates
- ✅ Changes persist on page refresh

---

## 🔬 TEST 6: Delete a Todo

**Browser UI:**
1. Open http://localhost:3000
2. Find a todo item
3. Click "Delete" button
4. Todo should disappear

### What to Look For
- ✅ Delete buttonworking
- ✅ Todo removed from list
- ✅ Removed from database

---

## 🔬 TEST 7: Check Backend Logs

### View Logs
```powershell
# Look at the terminal where backend is running (port 8080)
# You should see:

# Successful startup:
# "Listening on port 8080"

# API requests:
# POST /create
# GET /
# PUT /update/[id]
# DELETE /[id]
```

### What to Look For
- ✅ No red error messages
- ✅ Each API call is logged
- ✅ Database queries are working

---

## 🔬 TEST 8: Check Frontend Logs

### View Logs
```powershell
# Look at the terminal where frontend is running (port 3000)
# You should see:

# Successful startup:
# "Compiled successfully!"
# "You can now view the app in the browser"

# No fatal errors (warnings are OK)
```

### What to Look For
- ✅ "Compiled successfully" message
- ✅ No red errors (yellow warnings are fine)
- ✅ Frontend detected changes

---

## 📋 COMPLETE TESTING CHECKLIST

Use this checklist to verify everything works:

```
BACKEND TESTS:
[ ] Backend starts without errors
[ ] Backend listens on port 8080
[ ] Responds to HTTP requests
[ ] Logs show incoming API calls

FRONTEND TESTS:
[ ] Frontend starts without errors
[ ] Frontend loads on port 3000
[ ] Page displays todo application
[ ] No red errors in browser console

FUNCTIONALITY TESTS:
[ ] Can create a new todo
[ ] Can view all todos
[ ] Can edit an existing todo
[ ] Can delete a todo
[ ] All changes appear immediately

INTEGRATION TESTS:
[ ] Frontend communicates with backend
[ ] Todos saved to database
[ ] Changes persist after page refresh
[ ] No connection errors
```

---

## 🎯 Quick Test Summary

**Minimal Test (30 seconds):**
1. Open http://localhost:3000
2. Type "Test" and click Add
3. Verify todo appears
4. ✅ If this works, system is functioning!

**Complete Test (2 minutes):**
1. Create 3 todos
2. Edit one of them
3. Delete one of them
4. Refresh browser
5. Verify all operations persisted
6. ✅ Full application is working!

---

## 🐚 Port Verification Commands

### Check if ports are in use:

**Windows PowerShell:**
```powershell
# Check port 8080 (Backend)
netstat -ano | findstr :8080

# Check port 3000 (Frontend)
netstat -ano | findstr :3000

# Both should show node.exe or similar
```

### Expected Output:
```
TCP    0.0.0.0:8080      0.0.0.0:0       LISTENING    12345
TCP    0.0.0.0:3000      0.0.0.0:0       LISTENING    12346
```

If you see these lines, both servers are running!

---

## 🆘 If Tests Fail

### Backend not responding?
1. Check if terminal still shows "Listening on port 8080"
2. If crashed, restart: `npm start` in server directory
3. Check error messages in the terminal

### Frontend not loading?
1. Check http://localhost:3000 (not other ports)
2. Check browser console (F12) for errors
3. If crashed, restart: `npm start` in client directory

### Todos not saving?
1. Even without database, app should work locally
2. Check backend logs for errors
3. Verify API calls: `curl http://localhost:8080/`

---

## ✅ SUCCESS INDICATORS

**You're Good if:**
- ✅ Frontend displays without errors
- ✅ Can type and create todos
- ✅ Todos display in the list
- ✅ Can edit todos
- ✅ Can delete todos
- ✅ Changes appear instantly
- ✅ No connection errors
- ✅ Backend logs show API calls

**The Application is Working!** 🎉

---

## 📝 NEXT: Docker Compose Testing

Once you verify the npm setup works, test Docker Compose:

```bash
# Build Docker images
docker-compose build

# Start all services (MySQL, Backend, Frontend)
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Test
curl http://localhost:8080/
curl http://localhost:3000
```

See **TESTING_GUIDE.md** for complete Docker Compose testing procedures.

---

**Status**: ✅ Application Ready for Testing
**Current Setup**: Backend (8080) + Frontend (3000) running via npm
