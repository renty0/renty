import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd


COLORS = {
    'supply': '#3B82F6',
    'demand': '#F97316',
    'high_gap': '#DC2626',
    'mild_gap': '#FBBF24',
    'low_gap': '#10B981',
    'neutral': '#9CA3AF',
    'background': '#F9FAFB',
}


def create_kpi_card(title: str, value: str, subtitle: str = '', 
                   color: str = '#3B82F6') -> go.Figure:
    """
    Create a single KPI card.
    
    Args:
        title: KPI title
        value: Main metric value
        subtitle: Optional subtitle/explanation
        color: Card color
        icon: Optional emoji icon
    
    Returns:
        Plotly Figure object (annotation-based card)
    """
    fig = go.Figure()
    
    fig.add_annotation(
        text=f'<b>{title}</b><br><span style="font-size:24px;color:{color}">{value}</span><br><sub>{subtitle}</sub>',
        xref='paper', yref='paper',
        x=0.5, y=0.5,
        showarrow=False,
        font=dict(size=14, color='#111827', family='Inter, sans-serif'),
        bgcolor=f'rgba(255,255,255,0.9)',
        bordercolor=color,
        borderwidth=2,
        borderpad=20,
    )
    
    fig.update_layout(
        width=280,
        height=140,
        plot_bgcolor='white',
        paper_bgcolor='white',
        margin=dict(l=10, r=10, t=10, b=10),
        showlegend=False,
        xaxis=dict(visible=False),
        yaxis=dict(visible=False),
    )
    
    return fig


def create_dashboard_kpi_section(kpi_dict: dict) -> go.Figure:
    """
    Create KPI section with 4 key metrics.
    
    Args:
        kpi_dict: Dictionary with KPI values from get_kpi_metrics()
    
    Returns:
        Plotly Figure object
    """
    fig = make_subplots(
        rows=1, cols=4,
        specs=[[{'type': 'indicator'}, {'type': 'indicator'}, 
                {'type': 'indicator'}, {'type': 'indicator'}]],
        horizontal_spacing=0.12,
    )
    
    fig.add_trace(
        go.Indicator(
            mode='number+delta',
            value=kpi_dict['avg_gap_score'],
            title={'text': 'Avg Gap Score'},
            domain={'x': [0, 0.25], 'y': [0, 1]},
            number=dict(font=dict(size=28, color=COLORS['high_gap'])),
        ),
        row=1, col=1,
    )
    
    fig.add_trace(
        go.Indicator(
            mode='number+gauge',
            value=kpi_dict['max_gap_value'],
            title={'text': f"Highest Gap: {kpi_dict['max_gap_category']}"},
            domain={'x': [0.25, 0.5], 'y': [0, 1]},
            number=dict(font=dict(size=28, color=COLORS['high_gap'])),
        ),
        row=1, col=2,
    )
    
    fig.add_trace(
        go.Indicator(
            mode='number',
            value=kpi_dict['total_categories'],
            title={'text': 'Total Categories'},
            domain={'x': [0.5, 0.75], 'y': [0, 1]},
            number=dict(font=dict(size=28, color=COLORS['supply'])),
        ),
        row=1, col=3,
    )
    
    fig.add_trace(
        go.Indicator(
            mode='gauge+number',
            value=kpi_dict['high_gap_pct'],
            title={'text': 'High Gap %'},
            gauge=dict(
                axis=dict(range=[0, 100]),
                bar=dict(color=COLORS['high_gap']),
                threshold=dict(
                    line=dict(color='orange', width=4),
                    thickness=0.75,
                    value=50,
                ),
            ),
            domain={'x': [0.75, 1], 'y': [0, 1]},
            number=dict(font=dict(size=28, color=COLORS['high_gap']), suffix='%'),
        ),
        row=1, col=4,
    )
    
    fig.update_layout(
        plot_bgcolor='white',
        paper_bgcolor=COLORS['background'],
        font=dict(family='Inter, sans-serif', size=12, color='#374151'),
        height=200,
        margin=dict(l=20, r=20, t=20, b=20),
    )
    
    return fig


def export_chart_png(fig: go.Figure, filepath: str, width: int = 1080, 
                    height: int = 600) -> str:
    """
    Export Plotly figure as PNG.
    
    Args:
        fig: Plotly Figure object
        filepath: Output file path
        width: Image width
        height: Image height
    
    Returns:
        Path to saved file
    """
    try:
        fig.write_image(filepath, width=width, height=height, scale=2)
        return filepath
    except Exception as e:
        print(f"Note: PNG export requires kaleido. Install with: pip install kaleido")
        print(f"Error: {e}")
        html_path = filepath.replace('.png', '.html')
        fig.write_html(html_path)
        return html_path


def export_chart_html(fig: go.Figure, filepath: str) -> str:
    """
    Export Plotly figure as interactive HTML.
    
    Args:
        fig: Plotly Figure object
        filepath: Output file path
    
    Returns:
        Path to saved file
    """
    fig.write_html(filepath, include_plotlyjs='cdn')
    return filepath
