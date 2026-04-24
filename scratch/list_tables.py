from sqlalchemy import create_engine, text
engine = create_engine("postgresql://postgres:0000@localhost:5432/RentlyDb")
with engine.connect() as conn:
    result = conn.execute(text("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'"))
    for row in result:
        print(row[0])
