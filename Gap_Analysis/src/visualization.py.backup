import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd


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


def plot_missing_heatmap_collection(datasets: dict):
    """Plot missing data heatmaps for multiple datasets."""
    for name, df in datasets.items():
        missing_sum = df.isna().sum().sum()
        if missing_sum > 0:
            title = f"{name} ({missing_sum} missing values)"
            plot_missing_heatmap(df, title)
            plt.show()


def plot_missing_summary_bar(datasets: dict):
    """Generate summary dataframe of missing data across datasets."""
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
        return summary_df
    return None
