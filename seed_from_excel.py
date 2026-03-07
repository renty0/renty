import pandas as pd
from sqlalchemy import create_engine, text
import os
import traceback

# Configuration
CONN_STR = "postgresql://postgres:0000@localhost:5432/RentlyDb"
EXCEL_PATH = r"E:\Courses\Work\renty\Gap_Analysis\data\processed\Cleaned_data.xlsx"

def seed_database():
    try:
        print(f"Connecting to database...")
        engine = create_engine(CONN_STR)
        
        # Order of deletion (child tables first)
        tables_to_clear = [
            "Returns",
            "Sales",
            "RentRequests",
            "RentableItemImages",
            "RentableItems",
            "ProductImages",
            "Products",
            "ProductSubcategories",
            "ProductCategories",
            "Customers",
            "Territories",
            "Calendars"
        ]

        with engine.begin() as conn:
            print("Clearing existing data...")
            for table in tables_to_clear:
                conn.execute(text(f'TRUNCATE TABLE "{table}" CASCADE;'))
            print("Database cleared.")

        xl = pd.ExcelFile(EXCEL_PATH)
        
        # Helper to clean column names (remove leading/trailing spaces)
        def clean_df(df):
            df.columns = [c.strip() for c in df.columns]
            return df

        # Load data first to check date ranges
        print("Pre-loading data for range checks...")
        df_sales = clean_df(pd.read_excel(xl, "Sales Data"))
        df_returns = clean_df(pd.read_excel(xl, "Returns Data"))
        
        # Combine all dates to find the full range
        all_dates = pd.concat([
            df_sales["OrderDate"], 
            df_sales["StockDate"], 
            df_returns["ReturnDate"]
        ]).dropna()
        
        min_date = pd.to_datetime(all_dates.min())
        max_date = pd.to_datetime(all_dates.max())
        print(f"Required Calendar Range: {min_date.date()} to {max_date.date()}")

        # 1. Calendars (Dynamic Generation)
        print("Generating and Seeding Calendars...")
        date_range = pd.date_range(start=min_date, end=max_date)
        df_cal = pd.DataFrame({"Date": date_range})
        df_cal["DayName"] = df_cal["Date"].dt.day_name()
        df_cal["MonthName"] = df_cal["Date"].dt.month_name()
        df_cal["Month"] = df_cal["Date"].dt.month
        df_cal["Year"] = df_cal["Date"].dt.year
        df_cal["Quarter"] = (df_cal["Date"].dt.month - 1) // 3 + 1
        df_cal["StartOfWeek"] = df_cal["Date"] - pd.to_timedelta(df_cal["Date"].dt.dayofweek, unit='D')
        df_cal["StartOfMonth"] = df_cal["Date"].dt.to_period('M').dt.to_timestamp()
        df_cal["StartOfQuarter"] = df_cal["Date"].dt.to_period('Q').dt.to_timestamp()
        df_cal["StartOfYear"] = df_cal["Date"].dt.to_period('Y').dt.to_timestamp()
        
        df_cal["DayOfWeek"] = df_cal["Date"].dt.dayofweek
        df_cal["DayOfMonth"] = df_cal["Date"].dt.day
        df_cal["DayOfYear"] = df_cal["Date"].dt.dayofyear
        df_cal["WeekOfYear"] = df_cal["Date"].dt.isocalendar().week.astype(int)
        df_cal["IsWeekend"] = df_cal["DayOfWeek"].isin([5, 6])
        
        # Convert to date objects for PSQL compatibility
        for col in ["Date", "StartOfWeek", "StartOfMonth", "StartOfQuarter", "StartOfYear"]:
            df_cal[col] = df_cal[col].dt.date

        df_cal.to_sql("Calendars", engine, if_exists="append", index=False)

        # 2. Product Categories
        print("Seeding ProductCategories...")
        df_cat = clean_df(pd.read_excel(xl, "Product Category"))
        df_cat = df_cat.rename(columns={"ProductCategoryKey": "Id", "CategoryName": "CategoryName"})
        df_cat["Created"] = pd.Timestamp.now()
        df_cat["LastModified"] = pd.Timestamp.now()
        df_cat.to_sql("ProductCategories", engine, if_exists="append", index=False)

        # 3. Product Subcategories
        print("Seeding ProductSubcategories...")
        df_sub = clean_df(pd.read_excel(xl, "Product Subcategory"))
        df_sub = df_sub.rename(columns={
            "ProductSubcategoryKey": "Id",
            "SubcategoryName": "SubcategoryName",
            "ProductCategoryKey": "ProductCategoryId"
        })
        df_sub["Created"] = pd.Timestamp.now()
        df_sub["LastModified"] = pd.Timestamp.now()
        df_sub.to_sql("ProductSubcategories", engine, if_exists="append", index=False)

        # 4. Products
        print("Seeding Products...")
        df_prod = clean_df(pd.read_excel(xl, " Product Lookup"))
        df_prod = df_prod.rename(columns={
            "ProductKey": "Id",
            "ProductSubcategoryKey": "ProductSubcategoryId",
            "ProductSKU": "ProductSku",
            "ProductName": "ProductName",
            "ModelName": "ModelName",
            "ProductDescription": "ProductDescription",
            "ProductColor": "ProductColor",
            "ProductStyle": "ProductStyle",
            "ProductCost": "ProductCost",
            "ProductPrice": "ProductPrice",
            "SKU Type": "SkuType",
            "Discount Price": "DiscountPrice"
        })
        df_prod["Created"] = pd.Timestamp.now()
        df_prod["LastModified"] = pd.Timestamp.now()
        df_prod.to_sql("Products", engine, if_exists="append", index=False)

        # 5. Customers
        print("Seeding Customers...")
        df_cust = clean_df(pd.read_excel(xl, "Customer Lookup"))
        df_cust = df_cust.rename(columns={
            "CustomerKey": "Id",
            "Prefix": "Prefix",
            "FirstName": "FirstName",
            "LastName": "LastName",
            "BirthDate": "BirthDate",
            "MaritalStatus": "MaritalStatus",
            "Gender": "Gender",
            "EmailAddress": "EmailAddress",
            "AnnualIncome": "AnnualIncome",
            "TotalChildren": "TotalChildren",
            "EducationLevel": "EducationLevel",
            "Occupation": "Occupation",
            "HomeOwner": "HomeOwner",
            "Domain Name": "DomainName"
        })
        df_cust["BirthDate"] = pd.to_datetime(df_cust["BirthDate"]).dt.date
        df_cust["HomeOwner"] = df_cust["HomeOwner"].map({"Y": True, "N": False})
        df_cust["Created"] = pd.Timestamp.now()
        df_cust["LastModified"] = pd.Timestamp.now()
        if "Full Name" in df_cust.columns:
            df_cust = df_cust.drop(columns=["Full Name"])
        df_cust.to_sql("Customers", engine, if_exists="append", index=False)

        # 6. Territories
        print("Seeding Territories...")
        df_ter = clean_df(pd.read_excel(xl, "Territory Lookup"))
        df_ter = df_ter.rename(columns={
            "SalesTerritoryKey": "Id",
            "Region": "Region",
            "Country": "Country",
            "Continent": "Continent"
        })
        df_ter.to_sql("Territories", engine, if_exists="append", index=False)

        # 7. Sales
        print("Seeding Sales...")
        df_sales = df_sales.rename(columns={
            "OrderDate": "OrderDate",
            "StockDate": "StockDate",
            "OrderNumber": "OrderNumber",
            "ProductKey": "ProductId",
            "CustomerKey": "CustomerId",
            "TerritoryKey": "TerritoryId",
            "OrderLineItem": "OrderLineItem",
            "OrderQuantity": "OrderQuantity"
        })
        df_sales["OrderDate"] = pd.to_datetime(df_sales["OrderDate"]).dt.date
        df_sales["StockDate"] = pd.to_datetime(df_sales["StockDate"]).dt.date
        df_sales["Created"] = pd.Timestamp.now()
        df_sales["LastModified"] = pd.Timestamp.now()
        df_sales.to_sql("Sales", engine, if_exists="append", index=False)

        # 8. Returns
        print("Seeding Returns...")
        df_returns = df_returns.rename(columns={
            "ReturnDate": "ReturnDate",
            "TerritoryKey": "TerritoryId",
            "ProductKey": "ProductId",
            "ReturnQuantity": "ReturnQuantity"
        })
        df_returns["ReturnDate"] = pd.to_datetime(df_returns["ReturnDate"]).dt.date
        df_returns["Created"] = pd.Timestamp.now()
        df_returns["LastModified"] = pd.Timestamp.now()
        df_returns.to_sql("Returns", engine, if_exists="append", index=False)

        print("Seeding completed successfully!")

    except Exception as e:
        print(f"ERROR: {str(e)}")
        traceback.print_exc()

if __name__ == "__main__":
    seed_database()
