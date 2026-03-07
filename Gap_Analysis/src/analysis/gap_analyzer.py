import pandas as pd
from .config import TARGET_MULTIPLIERS

def calculate_gap(metrics_df):
    metrics_df['Target Value'] = metrics_df.apply(
        lambda row: row['Actual Value'] * TARGET_MULTIPLIERS.get(row['Metric'], 1), axis=1
    )
    metrics_df['Gap'] = metrics_df['Target Value'] - metrics_df['Actual Value']
    metrics_df['Gap %'] = (metrics_df['Gap'] / metrics_df['Actual Value']) * 100
    gap_score = metrics_df['Gap %'].mean()
    return metrics_df, gap_score
