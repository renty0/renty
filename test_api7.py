import urllib.request
import json
import subprocess

def test():
    # 1. Get API Token
    req = urllib.request.Request(
        "http://localhost:5106/api/account/login",
        data=json.dumps({"email": "admin@renty.com", "password": "Password123!"}).encode('utf-8'),
        headers={'Content-Type': 'application/json'}
    )
    try:
        response = urllib.request.urlopen(req)
        data = json.loads(response.read().decode('utf-8'))
        token = data['data']['token']['accessToken']
        
        # 2. Request API
        req2 = urllib.request.Request("http://localhost:5106/api/v1/support/tickets")
        req2.add_header("Authorization", f"Bearer {token}")
        response2 = urllib.request.urlopen(req2)
        data2 = json.loads(response2.read().decode('utf-8'))
        tickets = data2['data']['tickets']
        print(f"Total API tickets: {len(tickets)}")
        for t in tickets:
            print(t)
    except urllib.error.HTTPError as e:
        print(f"API Error {e.code}: {e.read().decode()}")

test()
