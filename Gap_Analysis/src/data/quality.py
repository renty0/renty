import matplotlib.pyplot as plt
import pandas as pd
from pathlib import Path
import seaborn as sns


def plot_missing_heatmap(df: pd.DataFrame, title: str = "Missing Data Heatmap"):
    """Create heatmap showing missing data patterns in dataframe."""
    fig, ax = plt.subplots(figsize=(12, 8))
    sns.heatmap(df.isna(), cbar=True, yticklabels=False, cmap='RdYlGn_r', ax=ax)
    ax.set_title(title)
    ax.set_xlabel("Columns")
    ax.set_ylabel("Rows")
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()
    return fig, ax


def plot_missing_summary(summary_df: pd.DataFrame):
    """Create bar charts for missing value counts and percentages."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))
    
    summary_df.plot(x='Column', y='Missing Count', kind='bar', ax=ax1, color='coral', legend=False)
    ax1.set_title('Missing Values Count')
    ax1.tick_params(axis='x', rotation=45)
    
    summary_df.plot(x='Column', y='Missing %', kind='bar', ax=ax2, color='steelblue', legend=False)
    ax2.set_title('Missing Values Percentage')
    ax2.tick_params(axis='x', rotation=45)
    
    plt.tight_layout()
    return fig, (ax1, ax2)


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