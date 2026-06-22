import psycopg2
import urllib.request
import json
import os

def test():
    # Direct DB query to verify tickets are Escalated and Unassigned
    conn = psycopg2.connect("postgresql://neondb_owner:npg_0hBeijOPT4cL@ep-sweet-shadow-ag0l2dna-pooler.c-2.eu-central-1.aws.neon.tech/rentyDB?sslmode=require")
    cur = conn.cursor()
    cur.execute('SELECT id, status, "AssignedAgentId", type FROM support_tickets WHERE status = \'Escalated\';')
    rows = cur.fetchall()
    print("DB Tickets:", rows)
    cur.close()
    conn.close()

try:
    import psycopg2
    test()
except ImportError:
    os.system("pip install psycopg2-binary")
    test()
