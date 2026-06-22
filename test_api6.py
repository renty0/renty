import psycopg2
import urllib.request
import json

def test():
    # 1. Direct DB Query
    try:
        conn = psycopg2.connect("postgresql://neondb_owner:npg_0hBeijOPT4cL@ep-sweet-shadow-ag0l2dna-pooler.c-2.eu-central-1.aws.neon.tech/rentyDB?sslmode=require")
        cur = conn.cursor()
        cur.execute('SELECT id, status, "AssignedAgentId", type FROM support_tickets WHERE status = \'Escalated\';')
        rows = cur.fetchall()
        print("DB Tickets:", rows)
        cur.close()
        conn.close()
    except Exception as e:
        print("DB Error:", e)

    # 2. Get API Token
    req = urllib.request.Request(
        "http://localhost:5106/api/account/login",
        data=json.dumps({"email": "admin@renty.com", "password": "Password123!"}).encode('utf-8'),
        headers={'Content-Type': 'application/json'}
    )
    try:
        response = urllib.request.urlopen(req)
        data = json.loads(response.read().decode('utf-8'))
        token = data['data']['token']['accessToken']
        
        # 3. Request API
        req2 = urllib.request.Request("http://localhost:5106/api/v1/support/tickets")
        req2.add_header("Authorization", f"Bearer {token}")
        response2 = urllib.request.urlopen(req2)
        data2 = json.loads(response2.read().decode('utf-8'))
        tickets = data2['data']['tickets']
        print(f"Total API tickets: {len(tickets)}")
    except Exception as e:
        print("API Error:", e)
        if hasattr(e, 'read'):
            print(e.read().decode())

try:
    import psycopg2
    test()
except ImportError:
    import os
    os.system("pip install psycopg2-binary > /dev/null")
    import psycopg2
    test()
