from sqlalchemy import create_engine, text
import traceback

CONN_STR = "postgresql://postgres:0000@localhost:5432/RentlyDb"

def cleanup_mock_data():
    try:
        print("Connecting to database for cleanup...")
        engine = create_engine(CONN_STR)
        
        with engine.begin() as conn:
            print("Removing stale mock data from GapAnalysisResults...")
            # Remove anything older than April 20th, 2026
            result = conn.execute(text('DELETE FROM "GapAnalysisResults" WHERE "CreatedAt" < \'2026-04-20\';'))
            print(f"Removed {result.rowcount} stale gap analysis records.")
            
            print("Removing stale mock data from fraud_logs...")
            result = conn.execute(text('DELETE FROM "fraud_logs" WHERE "created_at" < \'2026-04-20\';'))
            print(f"Removed {result.rowcount} stale fraud logs.")
            
        print("Cleanup completed successfully!")

    except Exception as e:
        print(f"ERROR: {str(e)}")
        traceback.print_exc()

if __name__ == "__main__":
    cleanup_mock_data()
