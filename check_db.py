import psycopg2

try:
    conn = psycopg2.connect("dbname=rentyDB user=postgres password=postgres host=localhost port=5433")
    cur = conn.cursor()
    cur.execute("SELECT id, type, status, \"AssignedAgentId\" FROM vw_supportticketssummary;")
    rows = cur.fetchall()
    print("Tickets:")
    for row in rows:
        print(row)
except Exception as e:
    print(e)
