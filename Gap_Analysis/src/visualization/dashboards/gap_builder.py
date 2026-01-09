import pandas as pd
import json
from pathlib import Path


def prepare_gap_summary(gap_df: pd.DataFrame, supply_col: str = 'UniqueProducts', 
                       demand_col: str = 'TotalQuantitySold', gap_col: str = 'GapScore') -> pd.DataFrame:
    """Prepare clean gap summary with all required metrics."""
    summary = gap_df.copy()
    required_cols = ['CategoryName', supply_col, demand_col, gap_col, 'GapLevel', 'NormalizedGapScore']
    summary = summary[[col for col in required_cols if col in summary.columns]]
    
    summary = summary.rename(columns={
        'CategoryName': 'category',
        supply_col: 'supply',
        demand_col: 'demand',
        gap_col: 'gap_score',
        'GapLevel': 'gap_status',
        'NormalizedGapScore': 'normalized_gap'
    })
    
    summary['gap_pct'] = ((summary['demand'] - summary['supply']) / (summary['supply'] + 1) * 100).round(2)
    return summary.sort_values('gap_score', ascending=False).reset_index(drop=True)


def export_gap_summary(summary_df: pd.DataFrame, output_dir: str = None) -> tuple:
    """Export gap summary to CSV and JSON."""
    if output_dir is None:
        output_dir = Path(__file__).parent.parent.parent / "results" / "data"
    
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    csv_path = output_dir / "gap_summary.csv"
    summary_df.to_csv(csv_path, index=False)
    
    json_path = output_dir / "gap_summary.json"
    with open(json_path, 'w') as f:
        json.dump(summary_df.to_dict(orient='records'), f, indent=2)
    
    return str(csv_path), str(json_path)


def get_kpi_metrics(summary_df: pd.DataFrame) -> dict:
    """Calculate KPIs for dashboard."""
    critical_high_count = len(summary_df[summary_df['gap_status'].isin(['High Gap', 'Critical Gap'])])
    
    return {
        'avg_gap_score': round(summary_df['gap_score'].mean(), 2),
        'max_gap_category': summary_df.loc[summary_df['gap_score'].idxmax(), 'category'],
        'max_gap_value': round(summary_df['gap_score'].max(), 2),
        'total_categories': len(summary_df),
        'high_gap_count': critical_high_count,
        'high_gap_pct': round(critical_high_count / len(summary_df) * 100, 1),
        'total_supply': int(summary_df['supply'].sum()),
        'total_demand': int(summary_df['demand'].sum()),
    }
