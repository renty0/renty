import pandas as pd
import numpy as np


def compute_gap_score(df: pd.DataFrame, demand_col: str = 'TotalQuantitySold', 
                     supply_col: str = 'UniqueProducts') -> pd.DataFrame:
    """
    Calculate gap score as ratio of demand to supply.
    Uses (demand + 1) / (supply + 1) to handle zero values.
    """
    df = df.copy()
    df['GapScore'] = (df[demand_col] + 1) / (df[supply_col] + 1)
    df['GapScore'] = df['GapScore'].round(2)
    return df


def normalize_gap_score(df: pd.DataFrame, gap_col: str = 'GapScore') -> pd.DataFrame:
    """Normalize gap scores to 0-1 range using min-max scaling."""
    df = df.copy()
    
    min_gap = df[gap_col].min()
    max_gap = df[gap_col].max()
    
    if max_gap - min_gap > 0:
        df['NormalizedGapScore'] = (df[gap_col] - min_gap) / (max_gap - min_gap)
    else:
        df['NormalizedGapScore'] = 0.0
    
    df['NormalizedGapScore'] = df['NormalizedGapScore'].round(4)
    return df


def classify_gap_level(df: pd.DataFrame, gap_col: str = 'GapScore') -> pd.DataFrame:
    """Classify gaps into severity levels based on score thresholds."""
    df = df.copy()
    
    def classify(score):
        if score < 50:
            return 'Low Gap'
        elif score < 100:
            return 'Moderate Gap'
        elif score < 200:
            return 'High Gap'
        else:
            return 'Critical Gap'
    
    df['GapLevel'] = df[gap_col].apply(classify)
    return df


def compute_demand_supply_ratio(df: pd.DataFrame) -> pd.DataFrame:
    """Calculate supplementary metrics for demand-supply analysis."""
    df = df.copy()
    
    df['AvgQuantityPerProduct'] = (df['TotalQuantitySold'] / (df['UniqueProducts'] + 1)).round(2)
    df['AvgQuantityPerOrder'] = (df['TotalQuantitySold'] / (df['UniqueOrders'] + 1)).round(2)
    df['CustomerOrderRatio'] = (df['UniqueCustomers'] / (df['UniqueOrders'] + 1)).round(2)
    
    return df


def rank_categories_by_gap(df: pd.DataFrame, gap_col: str = 'GapScore', 
                           ascending: bool = False) -> pd.DataFrame:
    """Sort categories by gap score and assign rank numbers."""
    df = df.copy()
    df = df.sort_values(by=gap_col, ascending=ascending)
    df['Rank'] = range(1, len(df) + 1)
    return df
