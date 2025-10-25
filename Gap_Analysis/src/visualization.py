import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd


def plot_missing_heatmap(df: pd.DataFrame, title: str = "Missing Data Heatmap"):
    fig, ax = plt.subplots(figsize=(12, 8))
    sns.heatmap(df.isna(), cbar=True, yticklabels=False, cmap='RdYlGn_r', ax=ax)
    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.set_xlabel("Columns", fontsize=12)
    ax.set_ylabel("Rows", fontsize=12)
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()
    return fig, ax


def plot_missing_summary(summary_df: pd.DataFrame):
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))
    
    summary_df.plot(x='Column', y='Missing Count', kind='bar', ax=ax1, color='coral', legend=False)
    ax1.set_title('Missing Values Count', fontsize=14, fontweight='bold')
    ax1.tick_params(axis='x', rotation=45)
    
    summary_df.plot(x='Column', y='Missing %', kind='bar', ax=ax2, color='steelblue', legend=False)
    ax2.set_title('Missing Values Percentage', fontsize=14, fontweight='bold')
    ax2.tick_params(axis='x', rotation=45)
    
    plt.tight_layout()
    return fig, (ax1, ax2)
