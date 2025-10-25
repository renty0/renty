import pandas as pd

def explore_structure(datasets: dict):
    for name, df in datasets.items():
        print("=" * 60)
        print(f"{name}")
        print("-" * 60)
        print(f"Shape: {df.shape}")
        print("\nData Types:")
        print(df.dtypes)
        print("\nColumns:")
        print(df.columns.tolist())
        print("\nUnique value count per column:")
        for col in df.columns:
            print(f"{col}: {df[col].nunique()} unique values")
        print("-" * 60)
        print(df.head(2))
        print("\n")


def infer_relationships(datasets: dict):
    possible_keys = {}
    for name, df in datasets.items():
        for col in df.columns:
            if "id" in col.lower():
                possible_keys.setdefault(col, []).append(name)

    print("Possible Key Relationships:")
    for key, tables in possible_keys.items():
        if len(tables) > 1:
            print(f" - '{key}' appears in {tables}")
    print("\n")