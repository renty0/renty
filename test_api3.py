import urllib.request
import json

def test():
    req = urllib.request.Request(
        "http://localhost:5106/api/v1/auth/login",
        data=json.dumps({"email": "admin@renty.com", "password": "Password123!"}).encode('utf-8'),
        headers={'Content-Type': 'application/json'}
    )
    try:
        response = urllib.request.urlopen(req)
        data = json.loads(response.read().decode('utf-8'))
        token = data['data']['token']['accessToken']
    except Exception as e:
        print("Login Error:", e)
        if hasattr(e, 'read'):
            print(e.read().decode())
        return

    req2 = urllib.request.Request("http://localhost:5106/api/v1/support/tickets")
    req2.add_header("Authorization", f"Bearer {token}")
    try:
        response2 = urllib.request.urlopen(req2)
        data2 = json.loads(response2.read().decode('utf-8'))
        tickets = data2['data']['tickets']
        print(f"Total tickets: {len(tickets)}")
        for t in tickets:
            print(f"[{t['type']}] {t['id']} | Status: {t['status']} | AssignedTo: {t['assignedAgentId']}")
    except Exception as e:
        print("Tickets Error:", e)

test()
