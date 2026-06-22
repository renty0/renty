import urllib.request
import json
import subprocess

# Get token
token_cmd = 'psql "postgresql://neondb_owner:npg_0hBeijOPT4cL@ep-sweet-shadow-ag0l2dna-pooler.c-2.eu-central-1.aws.neon.tech/rentyDB?sslmode=require" -t -c "SELECT \'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwiZW1haWwiOiJhZG1pbkByZW50eS5jb20iLCJqdGkiOiIwOTU1YThjYi00YTk0LTQ3MTQtYTM0OS1lMzFlYTU0NTQ5ODQiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AcmVudHkuY29tIiwiZmlyc3ROYW1lIjoiQWRtaW4iLCJsYXN0TmFtZSI6IlVzZXIiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJBZG1pbiIsImV4cCI6MTc4MjE1NjA3NiwiaXNzIjoiUmVudGx5LkFQSSIsImF1ZCI6IlJlbnRseS5DbGllbnQifQ.V1Y1Jt-Y65xV7aHl-LpYJ9Lq_lJqX2Vw7Z9p_Lq_lJq\'" -q'
token = subprocess.check_output(token_cmd, shell=True).decode('utf-8').strip()

req = urllib.request.Request("http://localhost:5106/api/v1/support/tickets")
req.add_header("Authorization", f"Bearer {token}")
try:
    response = urllib.request.urlopen(req)
    data = json.loads(response.read().decode('utf-8'))
    print(json.dumps(data, indent=2)[:2000])
except Exception as e:
    print("Error:", e)
