import pandas as pd
import json
from pathlib import Path
import plotly.graph_objects as go


def export_dataframe_to_files(df: pd.DataFrame, output_dir: Path, 
                              filename_base: str) -> tuple:
    """
    Export DataFrame to CSV and JSON formats.
    
    Args:
        df: DataFrame to export
        output_dir: Output directory path
        filename_base: Base filename without extension
    
    Returns:
        Tuple of (csv_path, json_path)
    """
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    csv_path = output_dir / f"{filename_base}.csv"
    df.to_csv(csv_path, index=False)
    
    json_path = output_dir / f"{filename_base}.json"
    with open(json_path, 'w') as f:
        json.dump(df.to_dict(orient='records'), f, indent=2)
    
    return str(csv_path), str(json_path)


def export_plotly_chart(fig: go.Figure, filepath: Path, format: str = 'html',
                       width: int = None, height: int = None) -> str:
    """
    Export Plotly figure to HTML or PNG.
    
    Args:
        fig: Plotly Figure object
        filepath: Output file path
        format: 'html' or 'png'
        width: Image width (for PNG)
        height: Image height (for PNG)
    
    Returns:
        Path to saved file
    """
    filepath = Path(filepath)
    filepath.parent.mkdir(parents=True, exist_ok=True)
    
    if format == 'html':
        fig.write_html(str(filepath), include_plotlyjs='cdn')
        return str(filepath)
    
    elif format == 'png':
        try:
            fig.write_image(str(filepath), width=width, height=height, scale=2)
            return str(filepath)
        except Exception as e:
            print(f"⚠ PNG export failed (install kaleido): pip install kaleido")
            html_path = str(filepath).replace('.png', '.html')
            fig.write_html(html_path, include_plotlyjs='cdn')
            return html_path
    
    else:
        raise ValueError(f"Unsupported format: {format}")


def export_insights_to_text(insights_dict: dict, filepath: Path) -> str:
    """
    Export insights dictionary to formatted text file.
    
    Args:
        insights_dict: Dictionary with insight keys and text values
        filepath: Output text file path
    
    Returns:
        Path to saved file
    """
    filepath = Path(filepath)
    filepath.parent.mkdir(parents=True, exist_ok=True)
    
    with open(filepath, 'w') as f:
        f.write("=" * 80 + "\n")
        f.write("GAP ANALYSIS INSIGHTS\n")
        f.write("=" * 80 + "\n\n")
        
        for title, content in insights_dict.items():
            f.write(f"{title.upper().replace('_', ' ')}\n")
            f.write("-" * 80 + "\n")
            f.write(content + "\n\n")
    
    return str(filepath)
