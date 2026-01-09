import os
import pandas as pd


def load_excel_sheets(file_path: str):
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"File not found: {file_path}")

    try:
        excel_file = pd.ExcelFile(file_path)
        dataframes = {}
        for sheet in excel_file.sheet_names:
            df = excel_file.parse(sheet_name=sheet)
            dataframes[sheet] = df

        return dataframes

    except Exception as e:
        print(f"Error: {e}")
        return {}


def summarize_excel_sheets(datasets: dict):
    summary = []
    for name, df in datasets.items():
        summary.append({
            "Sheet": name,
            "Rows": df.shape[0],
            "Columns": df.shape[1],
            "Missing Values": df.isna().sum().sum(),
            "Duplicates": df.duplicated().sum()
        })

    summary_df = pd.DataFrame(summary)
    return summary_df
