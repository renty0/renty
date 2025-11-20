import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots


PROFESSIONAL_COLORS = {
    'supply': '#3B82F6',
    'demand': '#F97316',
    'critical': '#DC2626',
    'warning': '#F59E0B',
    'balanced': '#16A34A',
    'bg_light': '#F9FAFB',
    'bg_white': '#FFFFFF',
    'text_dark': '#111827',
}

FONT_FAMILY = 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'


def calculate_kpis(df: pd.DataFrame) -> dict:
    """Calculate key performance indicators from gap summary."""
    critical_high = df[df['gap_status'].isin(['Critical Gap', 'High Gap'])].shape[0]
    high_gap_pct = round((critical_high / len(df) * 100), 1) if len(df) > 0 else 0
    
    kpis = {
        'avg_gap_score': round(df['gap_score'].mean(), 2),
        'highest_gap_category': df.loc[df['gap_score'].idxmax(), 'category'],
        'highest_gap_value': round(df['gap_score'].max(), 2),
        'total_categories': len(df),
        'critical_high_count': critical_high,
        'high_gap_pct': high_gap_pct,
        'total_supply': int(df['supply'].sum()),
        'total_demand': int(df['demand'].sum()),
    }
    
    return kpis


def create_kpi_cards(kpis: dict) -> go.Figure:
    """
    BEST PRACTICE VERSION:
    - Clear visual hierarchy
    - Contextual color coding
    - Proper labels and units
    - Status indicators (good/warning/critical zones)
    """
    fig = make_subplots(
        rows=1, cols=4,
        specs=[[
            {'type': 'indicator'},
            {'type': 'indicator'},
            {'type': 'indicator'},
            {'type': 'indicator'}
        ]],
        horizontal_spacing=0.10,
    )
    
    # KPI 1: Average Gap Score (most important - largest)
    fig.add_trace(
        go.Indicator(
            mode='number+delta',
            value=kpis['avg_gap_score'],
            title=dict(
                text='<b>Avg Gap Score</b>',
                font=dict(size=14, family=FONT_FAMILY)
            ),
            number=dict(
                font=dict(size=42, color=PROFESSIONAL_COLORS['critical']),
                suffix=''
            ),
            delta=dict(
                reference=200,  # Target threshold
                increasing=dict(color='red'),
                decreasing=dict(color='green')
            ),
            domain={'x': [0, 0.25], 'y': [0, 1]},
        ),
        row=1, col=1,
    )
    
    # KPI 2: Highest Gap Category (with full name, no truncation)
    fig.add_trace(
        go.Indicator(
            mode='number',
            value=kpis['highest_gap_value'],
            title=dict(
                text=f"<b>Highest Gap</b><br><sub style='font-size:10px'>{kpis['highest_gap_category']}</sub>",
                font=dict(size=12, family=FONT_FAMILY)
            ),
            number=dict(
                font=dict(size=36, color=PROFESSIONAL_COLORS['critical']),
                suffix=''
            ),
            domain={'x': [0.25, 0.5], 'y': [0, 1]},
        ),
        row=1, col=2,
    )
    
    # KPI 3: Total Categories (neutral color)
    fig.add_trace(
        go.Indicator(
            mode='number',
            value=kpis['total_categories'],
            title=dict(
                text='<b>Total Categories</b>',
                font=dict(size=14, family=FONT_FAMILY)
            ),
            number=dict(
                font=dict(size=42, color=PROFESSIONAL_COLORS['supply']),
                suffix=' cats'
            ),
            domain={'x': [0.5, 0.75], 'y': [0, 1]},
        ),
        row=1, col=3,
    )
    
    # KPI 4: High Gap % with CLEAR ZONES
    fig.add_trace(
        go.Indicator(
            mode='gauge+number+delta',
            value=kpis['high_gap_pct'],
            title=dict(
                text='<b>High Gap %</b>',
                font=dict(size=14, family=FONT_FAMILY)
            ),
            gauge=dict(
                axis=dict(range=[0, 100], tickwidth=1, tickcolor='darkgray'),
                bar=dict(color=PROFESSIONAL_COLORS['critical'], thickness=0.75),
                bgcolor='white',
                borderwidth=2,
                bordercolor='gray',
                steps=[
                    {'range': [0, 30], 'color': '#D1FAE5', 'name': 'Good'},      # Light green
                    {'range': [30, 60], 'color': '#FEF3C7', 'name': 'Warning'},  # Light yellow
                    {'range': [60, 100], 'color': '#FEE2E2', 'name': 'Critical'} # Light red
                ],
                threshold=dict(
                    line=dict(color='red', width=4),
                    thickness=0.75,
                    value=50  # Target threshold
                )
            ),
            number=dict(
                font=dict(size=32, color=PROFESSIONAL_COLORS['critical']),
                suffix='%'
            ),
            delta=dict(
                reference=50,
                increasing=dict(color='red', symbol='▲'),
                decreasing=dict(color='green', symbol='▼')
            ),
            domain={'x': [0.75, 1], 'y': [0, 1]},
        ),
        row=1, col=4,
    )
    
    fig.update_layout(
        plot_bgcolor=PROFESSIONAL_COLORS['bg_white'],
        paper_bgcolor=PROFESSIONAL_COLORS['bg_light'],
        font=dict(family=FONT_FAMILY, size=12, color=PROFESSIONAL_COLORS['text_dark']),
        height=220,  # Increased for better visibility
        margin=dict(l=30, r=30, t=80, b=30),
        title=dict(
            text='<b>Subcategory Gap Analysis - Executive KPI Dashboard</b>',
            font=dict(size=16, color=PROFESSIONAL_COLORS['text_dark'], family=FONT_FAMILY),
            x=0.5,
            xanchor='center',
        ),
    )
    
    return fig


def create_comprehensive_dashboard(gap_df: pd.DataFrame,
                                   supply_demand_fig,
                                   gap_severity_fig,
                                   heatmap_fig,
                                   ranking_fig,
                                   distribution_fig) -> go.Figure:
    """
    Assemble complete dashboard with all components:
    - Top: KPI cards
    - Middle: Gap Score chart
    - Bottom: Supply vs Demand + Heatmap + Rankings
    """
    kpis = calculate_kpis(gap_df)
    
    fig = make_subplots(
        rows=5, cols=2,
        subplot_titles=(
            '<b>Supply vs Demand</b>',
            '<b>Gap Severity Distribution</b>',
            '<b>Gap Analysis Heatmap</b>',
            '<b>Category Rankings</b>',
        ),
        specs=[
            [{'type': 'indicator', 'colspan': 2}, None],
            [{'type': 'bar'}, {'type': 'pie'}],
            [{'type': 'heatmap', 'colspan': 2}, None],
            [{'type': 'bar', 'colspan': 2}, None],
            [{'type': 'table', 'colspan': 2}, None],
        ],
        row_heights=[0.12, 0.25, 0.25, 0.25, 0.13],
        vertical_spacing=0.10,
        horizontal_spacing=0.12,
    )
    
    for trace in supply_demand_fig.data:
        fig.add_trace(trace, row=2, col=1)
    
    for trace in distribution_fig.data:
        fig.add_trace(trace, row=2, col=2)
    
    for trace in heatmap_fig.data:
        fig.add_trace(trace, row=3, col=1)
    
    for trace in ranking_fig.data:
        if trace.name:
            fig.add_trace(trace, row=4, col=1)
    
    summary_table = gap_df[['category', 'supply', 'demand', 'gap_score', 'gap_status']].head(8)
    
    fig.add_trace(
        go.Table(
            header=dict(
                values=['<b>Category</b>', '<b>Supply</b>', '<b>Demand</b>', '<b>Gap Score</b>', '<b>Status</b>'],
                fill_color=PROFESSIONAL_COLORS['supply'],
                font=dict(color='white', size=11, family=FONT_FAMILY),
                align='left',
            ),
            cells=dict(
                values=[
                    summary_table['category'],
                    summary_table['supply'].astype(int),
                    summary_table['demand'].astype(int),
                    summary_table['gap_score'].round(2),
                    summary_table['gap_status']
                ],
                fill_color='#F9FAFB',
                font=dict(size=10, family=FONT_FAMILY),
                align='left',
                height=24,
            ),
        ),
        row=5, col=1,
    )
    
    fig.update_layout(
        title=dict(
            text='<b>Supply–Demand Gap Analysis Dashboard</b><br><sub>Comprehensive Business Intelligence</sub>',
            font=dict(size=18, color=PROFESSIONAL_COLORS['text_dark'], family=FONT_FAMILY),
            x=0.5,
            xanchor='center',
        ),
        height=1600,
        showlegend=True,
        plot_bgcolor=PROFESSIONAL_COLORS['bg_light'],
        paper_bgcolor=PROFESSIONAL_COLORS['bg_white'],
        font=dict(family=FONT_FAMILY, size=11, color=PROFESSIONAL_COLORS['text_dark']),
    )
    
    return fig
