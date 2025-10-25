import pandas as pd
from IPython.display import display


def preview_all_datasets(datasets: dict, n_rows: int = 3):
    for name, df in datasets.items():
        print(f"\n{'='*60}")
        print(f"{name}")
        print('='*60)
        display(df.head(n_rows))


def check_duplicates(datasets: dict):
    for name, df in datasets.items():
        duplicates = df.duplicated().sum()
        print(f"{name}: {duplicates} duplicate rows")
        if duplicates > 0:
            display(df[df.duplicated(keep=False)].head())
        print()
