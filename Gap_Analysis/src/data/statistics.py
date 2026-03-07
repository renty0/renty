import pandas as pd
from IPython.display import display


def analyze_numerical_statistics(datasets: dict):
    for name, df in datasets.items():
        print(f"\n{'='*60}")
        print(f"{name}")
        print('='*60)
        
        numeric_cols = df.select_dtypes(include=['number']).columns
        if len(numeric_cols) > 0:
            display(df[numeric_cols].describe())
        print()


def analyze_categorical_distributions(datasets: dict):
    for name, df in datasets.items():
        print(f"\n{'='*60}")
        print(f"{name}")
        print('='*60)
        
        categorical_cols = df.select_dtypes(include=['object']).columns
        
        if len(categorical_cols) > 0:
            for col in categorical_cols:
                print(f"\n{col}:")
                print(df[col].value_counts())
                print(f"Unique values: {df[col].nunique()}")
                print("-" * 40)
        print()
