import json
import pandas as pd
from pathlib import Path
import plotly.graph_objects as go


def prepare_visualization_dataframe(gap_df: pd.DataFrame) -> pd.DataFrame:
    """Prepare clean DataFrame for visualization export."""
    summary = gap_df[['category', 'supply', 'demand', 'gap_score', 'gap_status']].copy()
    summary['gap_pct'] = ((summary['demand'] - summary['supply']) / (summary['supply'] + 1) * 100).round(2)
    summary['supply'] = summary['supply'].astype(int)
    summary['demand'] = summary['demand'].astype(int)
    summary['gap_score'] = summary['gap_score'].round(2)
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


def export_chart_html(fig: go.Figure, filepath: str, title: str = None) -> str:
    """Export Plotly figure as interactive HTML."""
    Path(filepath).parent.mkdir(parents=True, exist_ok=True)
    fig.write_html(filepath, include_plotlyjs='cdn')
    return filepath


def export_chart_png(fig: go.Figure, filepath: str, width: int = 1080, height: int = 600) -> str:
    """Export Plotly figure as PNG."""
    try:
        Path(filepath).parent.mkdir(parents=True, exist_ok=True)
        fig.write_image(filepath, width=width, height=height, scale=2)
        return filepath
    except Exception as e:
        html_path = str(filepath).replace('.png', '.html')
        export_chart_html(fig, html_path)
        return html_path


def create_insights_text(gap_df: pd.DataFrame) -> dict:
    """Generate textual insights for each chart."""
    highest_gap = gap_df.loc[gap_df['gap_score'].idxmax()]
    lowest_gap = gap_df.loc[gap_df['gap_score'].idxmin()]
    critical_count = len(gap_df[gap_df['gap_status'].isin(['Critical Gap', 'High Gap'])])
    
    return {
        'supply_demand': f"{highest_gap['category']}: {int(highest_gap['demand'])} demand vs {int(highest_gap['supply'])} supply ({highest_gap['gap_pct']:.1f}% gap)",
        'gap_severity': f"{critical_count}/{len(gap_df)} critical/high gaps. Worst: {highest_gap['category']} ({highest_gap['gap_score']:.2f})",
        'heatmap': f"Best balanced: {lowest_gap['category']} (gap: {lowest_gap['gap_score']:.2f})",
        'ranking': f"Top gaps range: {gap_df.nlargest(5, 'gap_score')['gap_score'].min():.2f} to {gap_df['gap_score'].max():.2f}",
    }
