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
    Create 4-card KPI section: Avg Gap Score, Highest Gap Category, Total Categories, % High Gap.
    """
    fig = make_subplots(
        rows=1, cols=4,
        specs=[[
            {'type': 'indicator'},
            {'type': 'indicator'},
            {'type': 'indicator'},
            {'type': 'indicator'}
        ]],
        horizontal_spacing=0.08,
    )
    
    fig.add_trace(
        go.Indicator(
            mode='number',
            value=kpis['avg_gap_score'],
            title=dict(text='Avg Gap Score', font=dict(size=13)),
            number=dict(font=dict(size=32, color=PROFESSIONAL_COLORS['critical']), prefix=''),
            domain={'x': [0, 0.25], 'y': [0, 1]},
        ),
        row=1, col=1,
    )
    
    fig.add_trace(
        go.Indicator(
            mode='number+delta',
            value=kpis['highest_gap_value'],
            title=dict(text=f"Highest: {kpis['highest_gap_category']}", font=dict(size=11)),
            number=dict(font=dict(size=28, color=PROFESSIONAL_COLORS['critical'])),
            domain={'x': [0.25, 0.5], 'y': [0, 1]},
        ),
        row=1, col=2,
    )
    
    fig.add_trace(
        go.Indicator(
            mode='number',
            value=kpis['total_categories'],
            title=dict(text='Total Categories', font=dict(size=13)),
            number=dict(font=dict(size=32, color=PROFESSIONAL_COLORS['supply'])),
            domain={'x': [0.5, 0.75], 'y': [0, 1]},
        ),
        row=1, col=3,
    )
    
    fig.add_trace(
        go.Indicator(
            mode='gauge+number',
            value=kpis['high_gap_pct'],
            title=dict(text='High Gap %', font=dict(size=13)),
            gauge=dict(
                axis=dict(range=[0, 100]),
                bar=dict(color=PROFESSIONAL_COLORS['critical']),
                steps=[
                    {'range': [0, 33], 'color': PROFESSIONAL_COLORS['balanced']},
                    {'range': [33, 66], 'color': PROFESSIONAL_COLORS['warning']},
                    {'range': [66, 100], 'color': PROFESSIONAL_COLORS['critical']},
                ],
            ),
            number=dict(font=dict(size=28, color=PROFESSIONAL_COLORS['critical']), suffix='%'),
            domain={'x': [0.75, 1], 'y': [0, 1]},
        ),
        row=1, col=4,
    )
    
    fig.update_layout(
        plot_bgcolor=PROFESSIONAL_COLORS['bg_light'],
        paper_bgcolor=PROFESSIONAL_COLORS['bg_white'],
        font=dict(family=FONT_FAMILY, size=11, color=PROFESSIONAL_COLORS['text_dark']),
        height=180,
        margin=dict(l=20, r=20, t=60, b=20),
        title=dict(
            text='<b>Gap Analysis KPI Overview</b>',
            font=dict(size=14, color=PROFESSIONAL_COLORS['text_dark'], family=FONT_FAMILY),
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
