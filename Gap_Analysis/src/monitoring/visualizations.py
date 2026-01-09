import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import numpy as np

COLORS = {
    'primary': '#3B82F6',
    'secondary': '#10B981',
    'critical': '#DC2626',
    'warning': '#F59E0B',
    'info': '#0EA5E9',
    'success': '#16A34A',
    'danger': '#EF4444',
    'bg_light': '#F9FAFB',
    'bg_white': '#FFFFFF',
    'border': '#E5E7EB',
    'text_dark': '#111827',
    'text_muted': '#6B7280',
}

FONT_FAMILY = 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'


def create_monitoring_kpi_cards(kpis: dict) -> go.Figure:
    fig = make_subplots(
        rows=1, cols=4,
        specs=[[
            {'type': 'indicator'},
            {'type': 'indicator'},
            {'type': 'indicator'},
            {'type': 'indicator'}
        ]],
        horizontal_spacing=0.12,
        column_widths=[0.22, 0.26, 0.22, 0.30]
    )
    
    fig.add_trace(
        go.Indicator(
            mode='number',
            value=kpis['total_categories'],
            title=dict(
                text='<b>Total Categories</b>',
                font=dict(size=13, family=FONT_FAMILY, color=COLORS['text_dark'])
            ),
            number=dict(
                font=dict(size=42, color=COLORS['primary'], family=FONT_FAMILY),
                valueformat=',',
            ),
            domain={'x': [0, 0.22], 'y': [0, 1]},
        ),
        row=1, col=1,
    )
    
    fig.add_trace(
        go.Indicator(
            mode='number',
            value=kpis['avg_gap_score'],
            title=dict(
                text='<b>Avg Gap Score</b>',
                font=dict(size=13, family=FONT_FAMILY, color=COLORS['text_dark'])
            ),
            number=dict(
                font=dict(size=42, color=COLORS['warning'], family=FONT_FAMILY),
                valueformat='.2f',
            ),
            domain={'x': [0.22, 0.48], 'y': [0, 1]},
        ),
        row=1, col=2,
    )
    
    fig.add_trace(
        go.Indicator(
            mode='number',
            value=kpis['critical_categories'],
            title=dict(
                text=f"<b>Critical</b><br><sub>({kpis['critical_pct']}%)</sub>",
                font=dict(size=13, family=FONT_FAMILY, color=COLORS['text_dark'])
            ),
            number=dict(
                font=dict(size=42, color=COLORS['critical'], family=FONT_FAMILY),
                valueformat=',',
            ),
            domain={'x': [0.48, 0.70], 'y': [0, 1]},
        ),
        row=1, col=3,
    )
    
    fig.add_trace(
        go.Indicator(
            mode='gauge+number',
            value=kpis['critical_pct'],
            title=dict(
                text='<b>Critical %</b>',
                font=dict(size=13, family=FONT_FAMILY, color=COLORS['text_dark'])
            ),
            gauge=dict(
                axis=dict(
                    range=[0, 100],
                    tickwidth=2,
                    tickcolor=COLORS['border'],
                    tickfont=dict(size=10, family=FONT_FAMILY)
                ),
                bar=dict(color=COLORS['critical'], thickness=0.9),
                bgcolor=COLORS['bg_light'],
                borderwidth=2,
                bordercolor=COLORS['border'],
                steps=[
                    {'range': [0, 30], 'color': '#DBEAFE'},
                    {'range': [30, 60], 'color': '#FEF08A'},
                    {'range': [60, 100], 'color': '#FECACA'}
                ],
                threshold=dict(
                    line=dict(color=COLORS['critical'], width=3),
                    thickness=0.9,
                    value=50
                )
            ),
            number=dict(
                font=dict(size=38, color=COLORS['critical'], family=FONT_FAMILY, weight='bold'),
                suffix='%',
                valueformat='.1f'
            ),
            domain={'x': [0.70, 1.0], 'y': [0, 1]},
        ),
        row=1, col=4,
    )
    
    fig.update_layout(
        plot_bgcolor=COLORS['bg_white'],
        paper_bgcolor=COLORS['bg_white'],
        font=dict(family=FONT_FAMILY, size=12, color=COLORS['text_dark']),
        height=240,
        margin=dict(l=20, r=20, t=80, b=20),
        title=dict(
            text='<b>Monitoring Overview - Key Performance Indicators</b>',
            font=dict(size=16, color=COLORS['text_dark'], family=FONT_FAMILY),
            x=0.5,
            xanchor='center',
            y=0.98,
            yanchor='top'
        ),
        showlegend=False,
    )
    
    return fig


def create_gap_trend_chart(historical_df: pd.DataFrame, top_n: int = 5) -> go.Figure:
    if 'date' not in historical_df.columns:
        return None
    
    historical_df = historical_df.copy()
    historical_df['date'] = pd.to_datetime(historical_df['date'])
    
    fig = go.Figure()
    
    top_categories = historical_df.groupby('category')['gap_score'].max().nlargest(top_n).index
    
    color_palette = [COLORS['critical'], COLORS['warning'], COLORS['info'], 
                     COLORS['primary'], COLORS['success']]
    
    for idx, category in enumerate(top_categories):
        category_data = historical_df[historical_df['category'] == category].sort_values('date')
        fig.add_trace(go.Scatter(
            x=category_data['date'],
            y=category_data['gap_score'],
            mode='lines+markers',
            name=category,
            line=dict(
                color=color_palette[idx % len(color_palette)],
                width=3,
                shape='spline'
            ),
            marker=dict(
                size=8,
                color=color_palette[idx % len(color_palette)],
                opacity=0.8,
                line=dict(color='white', width=2)
            ),
            hovertemplate='<b>%{fullData.name}</b><br>Date: %{x|%Y-%m-%d}<br>Gap Score: %{y:.2f}<extra></extra>',
            fill='tozeroy' if idx == 0 else None,
            fillcolor=f'rgba(59, 130, 246, 0.1)' if idx == 0 else None,
        ))
    
    fig.update_layout(
        title=dict(
            text='<b>Gap Score Trends (Top 5 Categories)</b>',
            font=dict(size=15, color=COLORS['text_dark'], family=FONT_FAMILY),
            x=0.5,
            xanchor='center'
        ),
        xaxis=dict(
            title='Date',
            gridcolor=COLORS['border'],
            showgrid=True,
            zeroline=False,
            linecolor=COLORS['border'],
            linewidth=1
        ),
        yaxis=dict(
            title='Gap Score',
            gridcolor=COLORS['border'],
            showgrid=True,
            zeroline=False
        ),
        hovermode='x unified',
        plot_bgcolor=COLORS['bg_light'],
        paper_bgcolor=COLORS['bg_white'],
        font=dict(family=FONT_FAMILY, size=11, color=COLORS['text_dark']),
        height=500,
        margin=dict(l=80, r=80, t=100, b=80),
        legend=dict(
            x=1.0,
            y=1.0,
            xanchor='right',
            yanchor='top',
            bgcolor=f'rgba(255, 255, 255, 0.8)',
            bordercolor=COLORS['border'],
            borderwidth=1
        ),
        hoverinfo='x+y'
    )
    
    return fig


def create_alert_table(flagged_df: pd.DataFrame) -> go.Figure:
    priority_colors = {
        'High': COLORS['critical'],
        'Medium': COLORS['warning'],
        'Low': COLORS['success'],
        'Normal': COLORS['text_muted']
    }
    
    cell_colors = []
    for priority in flagged_df['priority']:
        cell_colors.append(priority_colors.get(priority, COLORS['text_muted']))
    
    fig = go.Figure(data=[go.Table(
        header=dict(
            values=[
                '<b>Category</b>',
                '<b>Gap Score</b>',
                '<b>Change %</b>',
                '<b>Alerts</b>',
                '<b>Priority</b>'
            ],
            fill_color=COLORS['primary'],
            font=dict(
                color='white',
                size=12,
                family=FONT_FAMILY
            ),
            align='left',
            height=32,
            line=dict(color='white', width=2)
        ),
        cells=dict(
            values=[
                flagged_df['category'],
                flagged_df['gap_score'].round(2),
                flagged_df['gap_change_pct'].round(1),
                flagged_df['alerts'],
                flagged_df['priority']
            ],
            fill_color=[
                [COLORS['bg_light']] * len(flagged_df),
                [COLORS['bg_light']] * len(flagged_df),
                [COLORS['bg_light']] * len(flagged_df),
                [COLORS['bg_light']] * len(flagged_df),
                cell_colors
            ],
            font=dict(size=11, family=FONT_FAMILY, color=COLORS['text_dark']),
            align='left',
            height=32,
            line=dict(color=COLORS['border'], width=1)
        ),
    )])
    
    fig.update_layout(
        title=dict(
            text='<b>Active Alerts & Flags</b>',
            font=dict(size=15, color=COLORS['text_dark'], family=FONT_FAMILY),
            x=0.5,
            xanchor='center'
        ),
        height=max(600, len(flagged_df) * 35 + 100),
        plot_bgcolor=COLORS['bg_white'],
        paper_bgcolor=COLORS['bg_white'],
        font=dict(family=FONT_FAMILY, size=11, color=COLORS['text_dark']),
        margin=dict(l=20, r=20, t=80, b=20),
    )
    
    return fig


def create_change_heatmap(historical_df: pd.DataFrame) -> go.Figure:
    if 'date' not in historical_df.columns or 'gap_change_pct' not in historical_df.columns:
        return None
    
    historical_df = historical_df.copy()
    historical_df = historical_df.sort_values('date')
    pivot_data = historical_df.pivot(index='category', columns='date', values='gap_change_pct')
    
    fig = go.Figure(data=go.Heatmap(
        z=pivot_data.values,
        x=pivot_data.columns,
        y=pivot_data.index,
        colorscale=[
            [0, '#DC2626'],
            [0.25, '#F97316'],
            [0.5, '#FBBF24'],
            [0.75, '#10B981'],
            [1, '#16A34A']
        ],
        zmid=0,
        text=np.round(pivot_data.values, 1),
        texttemplate='%{text:.1f}',
        textfont=dict(size=10, family=FONT_FAMILY, color='white'),
        hovertemplate='<b>%{y}</b><br>%{x}<br>Change: %{z:.1f}%<extra></extra>',
        colorbar=dict(
            title='<b>Change %</b>',
            thickness=20,
            len=0.7,
            tickfont=dict(size=10, family=FONT_FAMILY)
        ),
        line=dict(color='white', width=1)
    ))
    
    fig.update_layout(
        title=dict(
            text='<b>Weekly Gap Change Heatmap</b>',
            font=dict(size=15, color=COLORS['text_dark'], family=FONT_FAMILY),
            x=0.5,
            xanchor='center'
        ),
        xaxis=dict(
            title='Date',
            showgrid=False,
            linecolor=COLORS['border'],
            linewidth=1
        ),
        yaxis=dict(
            title='Category',
            showgrid=False,
            linecolor=COLORS['border'],
            linewidth=1
        ),
        height=max(500, len(pivot_data) * 25),
        plot_bgcolor=COLORS['bg_white'],
        paper_bgcolor=COLORS['bg_white'],
        font=dict(family=FONT_FAMILY, size=11, color=COLORS['text_dark']),
        margin=dict(l=150, r=100, t=100, b=80),
    )
    
    return fig


def create_supply_demand_balance_chart(gap_df: pd.DataFrame) -> go.Figure:
    gap_df_sorted = gap_df.sort_values('gap_score', ascending=False).head(10)
    
    fig = make_subplots(
        rows=1, cols=1,
        specs=[[{"secondary_y": True}]],
    )
    
    fig.add_trace(
        go.Bar(
            x=gap_df_sorted['category'],
            y=gap_df_sorted['supply'],
            name='Supply',
            marker=dict(
                color=COLORS['primary'],
                opacity=0.85,
                line=dict(color='white', width=2)
            ),
            text=gap_df_sorted['supply'].astype(int),
            textposition='outside',
            textfont=dict(size=10, family=FONT_FAMILY, color=COLORS['primary']),
            hovertemplate='<b>%{x}</b><br>Supply: %{y:,} items<extra></extra>',
            offset=-0.2,
        ),
        secondary_y=False,
    )
    
    fig.add_trace(
        go.Bar(
            x=gap_df_sorted['category'],
            y=gap_df_sorted['demand'],
            name='Demand',
            marker=dict(
                color=COLORS['warning'],
                opacity=0.85,
                line=dict(color='white', width=2)
            ),
            text=gap_df_sorted['demand'].astype(int),
            textposition='outside',
            textfont=dict(size=10, family=FONT_FAMILY, color=COLORS['warning']),
            hovertemplate='<b>%{x}</b><br>Demand: %{y:,} units<extra></extra>',
            offset=0.2,
        ),
        secondary_y=True,
    )
    
    fig.update_layout(
        title=dict(
            text='<b>Supply vs Demand (Top 10 Gap Categories)</b>',
            font=dict(size=15, color=COLORS['text_dark'], family=FONT_FAMILY),
            x=0.5,
            xanchor='center'
        ),
        xaxis=dict(
            title='Category',
            showgrid=False,
            linecolor=COLORS['border'],
            linewidth=1,
            tickangle=-45
        ),
        barmode='group',
        bargap=0.15,
        bargroupgap=0.1,
        hovermode='x unified',
        plot_bgcolor=COLORS['bg_light'],
        paper_bgcolor=COLORS['bg_white'],
        font=dict(family=FONT_FAMILY, size=11, color=COLORS['text_dark']),
        height=550,
        margin=dict(l=80, r=80, t=100, b=120),
        legend=dict(
            x=0.5,
            y=1.08,
            xanchor='center',
            yanchor='top',
            orientation='h',
            bgcolor=f'rgba(255, 255, 255, 0.9)',
            bordercolor=COLORS['border'],
            borderwidth=1
        ),
    )
    
    fig.update_yaxes(
        title_text='<b>Supply (Count)</b>',
        title_font=dict(size=12, family=FONT_FAMILY, color=COLORS['primary']),
        gridcolor=COLORS['border'],
        linecolor=COLORS['primary'],
        linewidth=2,
        rangemode='tozero',
        showgrid=True,
        secondary_y=False
    )
    
    fig.update_yaxes(
        title_text='<b>Demand (Count)</b>',
        title_font=dict(size=12, family=FONT_FAMILY, color=COLORS['warning']),
        gridcolor='rgba(0,0,0,0)',
        linecolor=COLORS['warning'],
        linewidth=2,
        rangemode='tozero',
        showgrid=False,
        secondary_y=True
    )
    
    return fig
