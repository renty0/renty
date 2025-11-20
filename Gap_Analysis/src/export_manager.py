import json
import pandas as pd
from pathlib import Path
import plotly.graph_objects as go


def prepare_visualization_dataframe(gap_df: pd.DataFrame) -> pd.DataFrame:
    """Prepare clean DataFrame for visualization export (CSV/JSON)."""
    summary = gap_df[[
        'category', 'supply', 'demand', 'gap_score', 'gap_status'
    ]].copy()
    
    summary['gap_pct'] = ((summary['demand'] - summary['supply']) / 
                          (summary['supply'] + 1) * 100).round(2)
    
    summary['supply'] = summary['supply'].astype(int)
    summary['demand'] = summary['demand'].astype(int)
    summary['gap_score'] = summary['gap_score'].round(2)
    
    summary = summary.sort_values('gap_score', ascending=False).reset_index(drop=True)
    
    return summary


def export_gap_summary(summary_df: pd.DataFrame,
                      output_dir: str = None) -> tuple:
    """Export gap summary to CSV and JSON."""
    if output_dir is None:
        output_dir = Path(__file__).parent.parent / "results" / "data"
    
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    csv_path = output_dir / "gap_summary.csv"
    summary_df.to_csv(csv_path, index=False)
    print(f"✓ CSV exported: {csv_path}")
    
    json_path = output_dir / "gap_summary.json"
    with open(json_path, 'w') as f:
        json.dump(summary_df.to_dict(orient='records'), f, indent=2)
    print(f"✓ JSON exported: {json_path}")
    
    return str(csv_path), str(json_path)


def export_chart_html(fig: go.Figure, filepath: str, title: str = None) -> str:
    """Export Plotly figure as interactive HTML."""
    Path(filepath).parent.mkdir(parents=True, exist_ok=True)
    fig.write_html(filepath, include_plotlyjs='cdn')
    print(f"✓ HTML chart exported: {filepath}")
    return filepath


def export_chart_png(fig: go.Figure, filepath: str,
                    width: int = 1080, height: int = 600) -> str:
    """Export Plotly figure as PNG (requires kaleido)."""
    try:
        Path(filepath).parent.mkdir(parents=True, exist_ok=True)
        fig.write_image(filepath, width=width, height=height, scale=2)
        print(f"✓ PNG exported: {filepath}")
        return filepath
    except Exception as e:
        print(f"⚠ PNG export failed (install kaleido): {e}")
        html_path = str(filepath).replace('.png', '.html')
        export_chart_html(fig, html_path)
        return html_path


def create_insights_text(gap_df: pd.DataFrame) -> dict:
    """Generate textual insights for each chart."""
    highest_gap = gap_df.loc[gap_df['gap_score'].idxmax()]
    lowest_gap = gap_df.loc[gap_df['gap_score'].idxmin()]
    
    insights = {
        'supply_demand': f"""
SUPPLY VS DEMAND INSIGHT:
{highest_gap['category']} shows the largest demand-supply imbalance with 
{int(highest_gap['demand'])} units demanded but only {int(highest_gap['supply'])} listings available.
This represents a {highest_gap['gap_pct']:.1f}% gap requiring immediate attention.
        """.strip(),
        
        'gap_severity': f"""
GAP SEVERITY ANALYSIS:
{len(gap_df[gap_df['gap_status'].isin(['Critical Gap', 'High Gap'])])} out of {len(gap_df)} categories 
face critical or high gaps. {highest_gap['category']} with a score of {highest_gap['gap_score']:.2f} 
is the most severe case requiring supply expansion or demand management.
        """.strip(),
        
        'heatmap': f"""
NORMALIZED METRICS HEATMAP:
Red zones indicate high gaps requiring intervention. {lowest_gap['category']} demonstrates 
the healthiest balance with normalized metrics close to equilibrium (gap score: {lowest_gap['gap_score']:.2f}).
        """.strip(),
        
        'ranking': f"""
CATEGORY RANKINGS:
The top 5 under-supplied categories show gap scores ranging from {gap_df.nlargest(5, 'gap_score')['gap_score'].min():.2f} 
to {gap_df['gap_score'].max():.2f}. Well-balanced categories have scores below 50, indicating healthy market conditions.
        """.strip(),
    }
    
    return insights
