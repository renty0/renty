import pandas as pd
import os

data_dir = r"e:\Courses\Work\rently_2026\renty_recommendation\data\Cleaned"
files = ["GradProject_final_1.xlsx", "Project Data.xlsx"]

for f in files:
    path = os.path.join(data_dir, f)
    if os.path.exists(path):
        print(f"--- {f} ---")
        try:
            xl = pd.ExcelFile(path)
            print("Sheet names:", xl.sheet_names)
            for sheet in xl.sheet_names:
                print(f"  Shape of '{sheet}':", xl.parse(sheet).shape)
                print(f"  Columns of '{sheet}':", xl.parse(sheet).columns.tolist())
        except Exception as e:
            print(f"Error reading {f}: {e}")
