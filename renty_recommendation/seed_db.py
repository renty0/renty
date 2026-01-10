import pandas as pd
import numpy as np
from sqlalchemy import create_engine, text
import os
import datetime
import traceback

# Configuration
DATA_DIR = r"e:\Courses\Work\rently_2026\renty_recommendation\data\Cleaned"
DB_CONNECTION_STRING = "postgresql+psycopg2://postgres:0000@localhost:5432/RentlyDb"

def clean_db(conn):
    print("Cleaning existing data...")
    tables = [
        "RentRequests", "RentableItemImages", "RentableItems", 
        "Returns", "Sales", "Customers", "Products", 
        "ProductSubcategories", "ProductCategories", "Territories", "Calendars"
    ]
    for table in tables:
        try:
            if table == "Calendars":
                conn.execute(text(f'TRUNCATE TABLE "{table}" CASCADE'))
            else:
                conn.execute(text(f'TRUNCATE TABLE "{table}" RESTART IDENTITY CASCADE'))
        except Exception as e:
            print(f"Warning: Could not truncate {table}: {e}")
    conn.commit()

def run_seeding():
    print(f"Connecting to database at {DB_CONNECTION_STRING}...")
    try:
        engine = create_engine(DB_CONNECTION_STRING)
        
        # 1. Read Data
        print("Reading Excel files...")
        path1 = os.path.join(DATA_DIR, "GradProject_final_1.xlsx") 
        path2 = os.path.join(DATA_DIR, "Project Data.xlsx") 
        
        sales_df = pd.read_excel(path1)
        product_df = pd.read_excel(path2)
        print(f"Loaded Sales: {sales_df.shape}, Products: {product_df.shape}")
        
        sales_df.columns = sales_df.columns.str.strip()
        product_df.columns = product_df.columns.str.strip()

        with engine.connect() as conn:
            # 2. Clean DB
            clean_db(conn)

            # 3. Seed Territories 
            print("Seeding Territories...")
            conn.execute(text("""
                INSERT INTO "Territories" ("Region", "Country", "Continent")
                VALUES ('Default Region', 'Default Country', 'Default Continent')
            """))
            conn.commit()
            default_territory_id = conn.execute(text("SELECT \"Id\" FROM \"Territories\" LIMIT 1")).scalar()

            # 4. Seed Calendars 
            print("Seeding Calendars...")
            dates = pd.concat([sales_df['OrderDate'], sales_df['StockDate']]).unique()
            dates = [pd.to_datetime(d) for d in dates if pd.notna(d)]
            
            calendar_data = []
            for d in dates:
                d_date = d.date()
                calendar_data.append({
                    "Date": d_date,
                    "DayName": d.strftime("%A"),
                    "StartOfWeek": (d - datetime.timedelta(days=d.weekday())).date(),
                    "StartOfMonth": d.replace(day=1).date(),
                    "StartOfQuarter": d.replace(month=((d.month-1)//3)*3+1, day=1).date(),
                    "MonthName": d.strftime("%B"),
                    "Month": d.month,
                    "StartOfYear": d.replace(month=1, day=1).date(),
                    "Year": d.year,
                    "Quarter": (d.month-1)//3 + 1,
                    "DayOfWeek": d.weekday() + 1,
                    "DayOfMonth": d.day,
                    "DayOfYear": d.timetuple().tm_yday,
                    "WeekOfYear": d.isocalendar()[1],
                    "IsWeekend": d.weekday() >= 5
                })
                
            if calendar_data:
                conn.execute(text("""
                    INSERT INTO "Calendars" 
                    ("Date", "DayName", "StartOfWeek", "StartOfMonth", "StartOfQuarter", "MonthName", 
                     "Month", "StartOfYear", "Year", "Quarter", "DayOfWeek", "DayOfMonth", "DayOfYear", 
                     "WeekOfYear", "IsWeekend")
                    VALUES 
                    (:Date, :DayName, :StartOfWeek, :StartOfMonth, :StartOfQuarter, :MonthName, 
                     :Month, :StartOfYear, :Year, :Quarter, :DayOfWeek, :DayOfMonth, :DayOfYear, 
                     :WeekOfYear, :IsWeekend)
                    ON CONFLICT ("Date") DO NOTHING
                """), calendar_data)
                conn.commit()
            
            # 5. Seed Product Categories
            print("Seeding Product Categories...")
            conn.execute(text("INSERT INTO \"ProductCategories\" (\"CategoryName\") VALUES ('Default Category')"))
            conn.commit()
            default_category_id = conn.execute(text("SELECT \"Id\" FROM \"ProductCategories\" WHERE \"CategoryName\" = 'Default Category'")).scalar()

            # 6. Seed Product Subcategories
            print("Seeding Product Subcategories...")
            unique_subcats = product_df['ProductSubcategoryKey'].unique()
            subcat_values = []
            for sk in unique_subcats:
                if pd.notna(sk):
                    subcat_values.append({
                        "Id": int(sk),
                        "SubcategoryName": f"Subcategory {int(sk)}",
                        "ProductCategoryId": default_category_id
                    })
            
            if subcat_values:
                conn.execute(text("""
                    INSERT INTO "ProductSubcategories" ("Id", "SubcategoryName", "ProductCategoryId")
                    VALUES (:Id, :SubcategoryName, :ProductCategoryId)
                    ON CONFLICT ("Id") DO NOTHING
                """), subcat_values)
                conn.commit()
            
            # 7. Seed Products
            print("Seeding Products...")
            products_with_id = []
            valid_subcats = set([s['Id'] for s in subcat_values])
            
            for _, row in product_df.iterrows():
                sub_id = int(row['ProductSubcategoryKey']) if pd.notna(row['ProductSubcategoryKey']) else None
                products_with_id.append({
                    "Id": int(row['ProductKey']),
                    "ProductSku": row['ProductSKU'],
                    "ProductName": row['ProductName'],
                    "ModelName": row.get('ModelName'),
                    "ProductDescription": row.get('ProductDescription'),
                    "ProductColor": row.get('ProductColor'),
                    "ProductStyle": row.get('ProductStyle'),
                    "ProductCost": float(row['ProductCost']),
                    "ProductPrice": float(row['ProductPrice']),
                    "SkuType": row.get('SKU Type'),
                    "DiscountPrice": float(row['Discount Price']) if pd.notna(row['Discount Price']) else None,
                    "ProductSubcategoryId": sub_id
                })
                
            valid_products_id = [p for p in products_with_id if p['ProductSubcategoryId'] in valid_subcats]
            
            if valid_products_id:
                conn.execute(text("""
                    INSERT INTO "Products" 
                    ("Id", "ProductSku", "ProductName", "ModelName", "ProductDescription", "ProductColor", "ProductStyle", 
                     "ProductCost", "ProductPrice", "SkuType", "DiscountPrice", "ProductSubcategoryId", 
                     "Created", "CreatedBy", "LastModified", "LastModifiedBy")
                    VALUES 
                    (:Id, :ProductSku, :ProductName, :ModelName, :ProductDescription, :ProductColor, :ProductStyle,
                     :ProductCost, :ProductPrice, :SkuType, :DiscountPrice, :ProductSubcategoryId, 
                     NOW(), 'Seeder', NOW(), 'Seeder')
                    ON CONFLICT ("Id") DO NOTHING
                """), valid_products_id)
                conn.commit()
            
            # 8. Seed Customers
            print("Seeding Customers...")
            unique_customers = sales_df['CustomerKey'].unique()
            customers_to_insert = []
            for ck in unique_customers:
                customers_to_insert.append({
                    "Id": int(ck),
                    "FirstName": "Customer",
                    "LastName": str(int(ck)),
                    "EmailAddress": f"customer{int(ck)}@example.com"
                })
                
            if customers_to_insert:
                conn.execute(text("""
                    INSERT INTO "Customers" ("Id", "FirstName", "LastName", "EmailAddress", 
                                           "Created", "CreatedBy", "LastModified", "LastModifiedBy")
                    VALUES (:Id, :FirstName, :LastName, :EmailAddress, 
                            NOW(), 'Seeder', NOW(), 'Seeder')
                    ON CONFLICT ("Id") DO NOTHING
                """), customers_to_insert)
                conn.commit()

            # 9. Seed Sales
            print("Seeding Sales...")
            sales_to_insert = []
            valid_product_ids = set([p['Id'] for p in valid_products_id])
            valid_customer_ids = set([c['Id'] for c in customers_to_insert])

            for _, row in sales_df.iterrows():
                p_id = int(row['ProductKey'])
                c_id = int(row['CustomerKey'])
                if p_id in valid_product_ids and c_id in valid_customer_ids:
                    sales_to_insert.append({
                        "OrderNumber": str(row['OrderNumber']),
                        "OrderDate": pd.to_datetime(row['OrderDate']).date(),
                        "StockDate": pd.to_datetime(row['StockDate']).date() if pd.notna(row['StockDate']) else None,
                        "OrderLineItem": int(row['OrderLineItem']) if 'OrderLineItem' in row else 1,
                        "OrderQuantity": int(row['OrderQuantity']) if 'OrderQuantity' in row else 1,
                        "ProductId": p_id,
                        "CustomerId": c_id,
                        "TerritoryId": default_territory_id
                    })

            if sales_to_insert:
                # Insert in chunks to avoid memory/packet issues
                chunk_size = 5000
                for i in range(0, len(sales_to_insert), chunk_size):
                    chunk = sales_to_insert[i:i + chunk_size]
                    conn.execute(text("""
                        INSERT INTO "Sales" 
                        ("OrderNumber", "OrderDate", "StockDate", "OrderLineItem", "OrderQuantity", 
                         "ProductId", "CustomerId", "TerritoryId", 
                         "Created", "CreatedBy", "LastModified", "LastModifiedBy")
                        VALUES 
                        (:OrderNumber, :OrderDate, :StockDate, :OrderLineItem, :OrderQuantity, 
                         :ProductId, :CustomerId, :TerritoryId, 
                         NOW(), 'Seeder', NOW(), 'Seeder')
                    """), chunk)
                conn.commit()
                
            print("Seeding Complete!")
            
    except Exception as e:
        print(f"Failed: {e}")
        traceback.print_exc()

if __name__ == "__main__":
    run_seeding()
