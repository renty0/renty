import pandas as pd

file_path = r'E:\Courses\Work\renty\Gap_Analysis\data\processed\Cleaned_data.xlsx'
xl = pd.ExcelFile(file_path)

# Analyze each sheet
for sheet_name in xl.sheet_names:
    df = pd.read_excel(file_path, sheet_name=sheet_name)
    
    print(f"\n{'='*60}")
    print(f"Sheet: {sheet_name.strip()}")
    print(f"{'='*60}")
    print(f"Rows: {len(df)}")
    print(f"Columns ({len(df.columns)}): {', '.join(df.columns)}")
    print(f"\nFirst row:")
    if len(df) > 0:
        for col in df.columns:
            val = df[col].iloc[0]
            print(f"  {col}: {val} ({type(val).__name__})")
