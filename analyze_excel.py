import pandas as pd
import json

file_path = r'E:\Courses\Work\renty\Gap_Analysis\data\processed\Cleaned_data.xlsx'

# Read all sheets
xl = pd.ExcelFile(file_path)

print("=" * 80)
print("EXCEL FILE ANALYSIS")
print("=" * 80)

for sheet_name in xl.sheet_names:
    df = pd.read_excel(file_path, sheet_name=sheet_name)
    
    print(f"\n{sheet_name.strip()}:")
    print(f"  Rows: {len(df)}")
    print(f"  Columns: {list(df.columns)}")
    print(f"\n  Sample data (first 2 rows):")
    print(df.head(2).to_string(index=False))
    print("\n" + "=" * 80)
