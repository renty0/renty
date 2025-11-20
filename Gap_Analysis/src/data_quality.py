import matplotlib.pyplot as plt
import pandas as pd
from pathlib import Path
from .visualization import plot_missing_heatmap, plot_missing_summary


def print_missing_data(datasets: dict):
    """Print missing data summary for each dataset."""
    for name, df in datasets.items():
        missing_count = df.isna().sum()
        total_missing = missing_count.sum()
        
        print(f"{'='*60}")
        print(f"{name}:")
        print(f"{'='*60}")
        
        if total_missing > 0:
            print(missing_count[missing_count > 0])
            print(f"\nTotal: {total_missing} ({(total_missing / df.size) * 100:.2f}%)")
        else:
            print("No missing values found.")
        print("\n")


def plot_missing_heatmaps(datasets: dict):
    """Create heatmaps showing missing data patterns."""
    for name, df in datasets.items():
        missing_sum = df.isna().sum().sum()
        
        if missing_sum > 0:
            title = f"{name} ({missing_sum} missing values)"
            fig, ax = plot_missing_heatmap(df, title)
            plt.show()


def plot_missing_summary_bar(datasets: dict):
    """Create bar chart summary of missing data."""
    summary_data = []
    
    for name, df in datasets.items():
        for col in df.columns:
            missing_count = df[col].isna().sum()
            if missing_count > 0:
                summary_data.append({
                    'Dataset': name,
                    'Column': col,
                    'Missing Count': missing_count,
                    'Missing %': round((missing_count / len(df)) * 100, 2)
                })
    
    if summary_data:
        summary_df = pd.DataFrame(summary_data)
        fig, axes = plot_missing_summary(summary_df)
        plt.show()
        return summary_df
    else:
        print("No missing values found in any dataset.")
        return None