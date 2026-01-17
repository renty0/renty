
from sqlalchemy import create_engine, text
import os

CONN_STR = "postgresql://postgres:0000@localhost:5432/RentlyDb"

def check_dates():
    try:
        engine = create_engine(CONN_STR)
        with engine.connect() as conn:
            result = conn.execute(text('SELECT MIN("OrderDate"), MAX("OrderDate"), COUNT(*) FROM "Sales";')).fetchone()
            print(f"Sales Data: Min Date: {result[0]}, Max Date: {result[1]}, Count: {result[2]}")
            
            # Also check a few recent records
            recent = conn.execute(text('SELECT "OrderDate" FROM "Sales" ORDER BY "OrderDate" DESC LIMIT 5;')).fetchall()
            print("Recent Sales Dates:")
            for r in recent:
                print(r[0])
                
    except Exception as e:
        print(f"ERROR: {str(e)}")

if __name__ == "__main__":
    check_dates()
