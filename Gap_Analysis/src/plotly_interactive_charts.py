import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import numpy as np


PROFESSIONAL_COLORS = {
    'supply': '#3B82F6',
    'demand': '#F97316',
    'critical': '#DC2626',
    'warning': '#F59E0B',
    'mild': '#FBBF24',
    'balanced': '#16A34A',
    'neutral': '#9CA3AF',
    'bg_light': '#F9FAFB',
    'bg_white': '#FFFFFF',
    'text_dark': '#111827',
    'text_muted': '#6B7280',
}

FONT_FAMILY = 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'


def create_supply_demand_chart(df: pd.DataFrame) -> go.Figure:
    """
    Create professional supply vs demand visualization using dual Y-axes.
    BEST PRACTICE: Each metric on its own appropriately-scaled axis.
    This is the industry standard for comparing metrics with different magnitudes.
    """
    df_sorted = df.sort_values('gap_score', ascending=False)
    
    fig = make_subplots(specs=[[{"secondary_y": True}]])
    
    
    fig.add_trace(
        go.Bar(
            x=df_sorted['category'],
            y=df_sorted['supply'],
            name='Supply (Products)',
            marker=dict(
                color=PROFESSIONAL_COLORS['supply'],
                line=dict(color='white', width=1),
                opacity=0.85
            ),
            text=df_sorted['supply'].astype(int),
            textposition='outside',
            textfont=dict(size=9, color=PROFESSIONAL_COLORS['supply'], family=FONT_FAMILY),
            hovertemplate='<b>%{x}</b><br>Supply: %{y:,} products<extra></extra>',
            offsetgroup=0,
        ),
        secondary_y=False
    )
    
    
    fig.add_trace(
        go.Bar(
            x=df_sorted['category'],
            y=df_sorted['demand'],
            name='Demand (Orders)',
            marker=dict(
                color=PROFESSIONAL_COLORS['demand'],
                line=dict(color='white', width=1),
                opacity=0.85
            ),
            text=df_sorted['demand'].astype(int),
            textposition='outside',
            textfont=dict(size=9, color=PROFESSIONAL_COLORS['demand'], family=FONT_FAMILY),
            hovertemplate='<b>%{x}</b><br>Demand: %{y:,} orders<extra></extra>',
            offsetgroup=1,
        ),
        secondary_y=True
    )
    
    fig.update_layout(
        title=dict(
            text='<b>Supply vs Demand by Category</b><br><sub>Independent Y-axes ensure both metrics are clearly visible</sub>',
            font=dict(size=16, color=PROFESSIONAL_COLORS['text_dark'], family=FONT_FAMILY),
            x=0.5,
            xanchor='center'
        ),
        barmode='group',
        bargap=0.15,
        bargroupgap=0.1,
        xaxis=dict(
            title='Category',
            title_font=dict(size=12, family=FONT_FAMILY),
            showgrid=False,
            linecolor='#E5E7EB',
            linewidth=1,
            tickangle=-45
        ),
        hovermode='x unified',
        plot_bgcolor=PROFESSIONAL_COLORS['bg_light'],
        paper_bgcolor=PROFESSIONAL_COLORS['bg_white'],
        font=dict(family=FONT_FAMILY, size=11, color=PROFESSIONAL_COLORS['text_dark']),
        height=600,
        margin=dict(l=70, r=70, t=100, b=120),
        showlegend=True,
        legend=dict(
            x=0.5,
            y=1.08,
            xanchor='center',
            yanchor='top',
            orientation='h',
            bgcolor='rgba(255,255,255,0.9)',
            bordercolor='#E5E7EB',
            borderwidth=1,
        ),
    )
    
    
    fig.update_yaxes(
        title_text='<b style="color:#3B82F6">Supply (Products)</b>',
        title_font=dict(size=12, family=FONT_FAMILY),
        gridcolor='#E5E7EB',
        linecolor='#3B82F6',
        linewidth=2,
        rangemode='tozero',
        showgrid=True,
        secondary_y=False
    )
    
    
    fig.update_yaxes(
        title_text='<b style="color:#F97316">Demand (Orders)</b>',
        title_font=dict(size=12, family=FONT_FAMILY),
        gridcolor='rgba(0,0,0,0)',
        linecolor='#F97316',
        linewidth=2,
        rangemode='tozero',
        showgrid=False,
        secondary_y=True
    )
    
    return fig


import plotly.express as px
import plotly.graph_objects as go

def create_gap_score_severity_chart(df: pd.DataFrame):
    """
    BEST PRACTICE VERSION:
    Uses normalized linear scale instead of log scale.
    - Avoids distortion
    - Avoids huge empty space
    - Keeps differences visible
    - Industry standard for severity dashboards
    """
    df = df.copy()

    
    min_g, max_g = df["gap_score"].min(), df["gap_score"].max()
    df["gap_score_norm"] = ((df["gap_score"] - min_g) / (max_g - min_g)) * 100

    
    df = df.sort_values("gap_score_norm", ascending=True)

    severity_colors = {
        "Critical Gap": "#d62728",
        "High Gap": "#ff7f0e",
        "Moderate Gap": "#ffbf00",
        "Low Gap": "#2ca02c",
    }

    fig = px.bar(
        df,
        x="gap_score_norm",
        y="category",
        orientation="h",
        color="gap_status",
        color_discrete_map=severity_colors,
        text=df["gap_score"].apply(lambda x: f"{x:.1f}"),
        title="Gap Score Severity Analysis (Normalized 0–100 Scale)",
    )

    fig.update_xaxes(title="Normalized Severity (0–100)")
    fig.update_yaxes(title="Category")

    fig.update_layout(
        font=dict(family="Arial", size=14),
        title=dict(font=dict(size=26)),
        legend=dict(title="Severity Level"),
        plot_bgcolor="#F9FAFB",
        paper_bgcolor="white",
    )

    
    ranked = df.sort_values("gap_score_norm", ascending=False).head(3)
    for i, row in ranked.iterrows():
        fig.add_annotation(
            x=row["gap_score_norm"],
            y=row["category"],
            text=f"#{ranked.index.get_loc(i)+1}",
            showarrow=True,
            arrowhead=2,
            ax=40,
            ay=0,
            font=dict(color="red", size=14, weight="bold"),
            bgcolor="white"
        )

    return fig



def create_gap_heatmap(df: pd.DataFrame) -> go.Figure:
    """
    Create normalized metrics heatmap (supply, demand, gap_score).
    """
    df_sorted = df.sort_values('gap_score', ascending=False)
    
    def normalize_col(col):
        min_val = df_sorted[col].min()
        max_val = df_sorted[col].max()
        if max_val - min_val == 0:
            return [0.5] * len(df_sorted)
        return (df_sorted[col] - min_val) / (max_val - min_val)
    
    heatmap_data = {
        'Supply': normalize_col('supply'),
        'Demand': normalize_col('demand'),
        'Gap Score': normalize_col('gap_score'),
    }
    
    z_values = [heatmap_data[metric] for metric in ['Supply', 'Demand', 'Gap Score']]
    
    fig = go.Figure(data=go.Heatmap(
        z=z_values,
        x=df_sorted['category'],
        y=['Supply', 'Demand', 'Gap Score'],
        colorscale='RdYlGn_r',
        text=[[f'{val:.2f}' for val in row] for row in z_values],
        texttemplate='%{text}',
        textfont=dict(size=11, color=PROFESSIONAL_COLORS['text_dark']),
        hovertemplate='<b>%{y}</b><br>%{x}<br>Normalized: %{z:.3f}<extra></extra>',
        colorbar=dict(
            title='Normalized<br>Value',
            thickness=15,
            len=0.7,
            x=1.02,
        ),
    ))
    
    fig.update_layout(
        title=dict(
            text='<b>Gap Analysis Heatmap</b><br><sub>Normalized Metrics (0-1 Scale)</sub>',
            font=dict(size=16, color=PROFESSIONAL_COLORS['text_dark'], family=FONT_FAMILY),
            x=0.5,
            xanchor='center'
        ),
        xaxis=dict(
            title='Category',
            title_font=dict(size=12, family=FONT_FAMILY),
            showgrid=False,
            linecolor='#E5E7EB',
            linewidth=1,
        ),
        yaxis=dict(
            title='Metric',
            title_font=dict(size=12, family=FONT_FAMILY),
            showgrid=False,
            linecolor='#E5E7EB',
            linewidth=1,
        ),
        plot_bgcolor=PROFESSIONAL_COLORS['bg_white'],
        paper_bgcolor=PROFESSIONAL_COLORS['bg_white'],
        font=dict(family=FONT_FAMILY, size=11, color=PROFESSIONAL_COLORS['text_dark']),
        height=400,
        margin=dict(l=100, r=100, t=100, b=60),
    )
    
    return fig


def create_category_ranking_chart(df: pd.DataFrame, top_n: int = 5) -> go.Figure:
    """
    Create dual horizontal ranking: top N under-supplied and bottom N balanced.
    """
    top_gaps = df.nlargest(top_n, 'gap_score')
    bottom_gaps = df.nsmallest(top_n, 'gap_score')
    
    fig = make_subplots(
        rows=1, cols=2,
        subplot_titles=(
            f'<b>Top {top_n} Under-Supplied</b>',
            f'<b>Bottom {top_n} Well-Balanced</b>'
        ),
        specs=[[{'type': 'bar'}, {'type': 'bar'}]],
        horizontal_spacing=0.15,
    )
    
    fig.add_trace(
        go.Bar(
            y=top_gaps['category'],
            x=top_gaps['gap_score'],
            orientation='h',
            marker=dict(
                color=PROFESSIONAL_COLORS['critical'],
                line=dict(color='white', width=1)
            ),
            text=top_gaps['gap_score'].apply(lambda x: f'{x:.2f}'),
            textposition='outside',
            hovertemplate='<b>%{y}</b><br>Gap: %{x:.2f}<extra></extra>',
            name='High Gap',
        ),
        row=1, col=1,
    )
    
    fig.add_trace(
        go.Bar(
            y=bottom_gaps['category'],
            x=bottom_gaps['gap_score'],
            orientation='h',
            marker=dict(
                color=PROFESSIONAL_COLORS['balanced'],
                line=dict(color='white', width=1)
            ),
            text=bottom_gaps['gap_score'].apply(lambda x: f'{x:.2f}'),
            textposition='outside',
            hovertemplate='<b>%{y}</b><br>Gap: %{x:.2f}<extra></extra>',
            name='Low Gap',
        ),
        row=1, col=2,
    )
    
    fig.update_xaxes(
        title_text='Gap Score',
        gridcolor='#E5E7EB',
        linecolor='#E5E7EB',
        linewidth=1,
        row=1, col=1
    )
    fig.update_xaxes(
        title_text='Gap Score',
        gridcolor='#E5E7EB',
        linecolor='#E5E7EB',
        linewidth=1,
        row=1, col=2
    )
    
    fig.update_yaxes(
        showgrid=False,
        linecolor='#E5E7EB',
        linewidth=1,
        row=1, col=1
    )
    fig.update_yaxes(
        showgrid=False,
        linecolor='#E5E7EB',
        linewidth=1,
        row=1, col=2
    )
    
    fig.update_layout(
        title=dict(
            text='<b>Category Rankings: Highest & Lowest Gaps</b>',
            font=dict(size=16, color=PROFESSIONAL_COLORS['text_dark'], family=FONT_FAMILY),
            x=0.5,
            xanchor='center'
        ),
        plot_bgcolor=PROFESSIONAL_COLORS['bg_light'],
        paper_bgcolor=PROFESSIONAL_COLORS['bg_white'],
        font=dict(family=FONT_FAMILY, size=11, color=PROFESSIONAL_COLORS['text_dark']),
        height=500,
        margin=dict(l=80, r=80, t=100, b=60),
        showlegend=False,
    )
    
    return fig


def create_gap_distribution_pie(df: pd.DataFrame) -> go.Figure:
    """
    Create pie chart showing distribution of gap severity levels.
    """
    def get_gap_color(status):
        status_colors = {
            'Critical Gap': PROFESSIONAL_COLORS['critical'],
            'High Gap': PROFESSIONAL_COLORS['warning'],
            'Moderate Gap': PROFESSIONAL_COLORS['mild'],
            'Low Gap': PROFESSIONAL_COLORS['balanced'],
        }
        return status_colors.get(status, PROFESSIONAL_COLORS['neutral'])
    
    gap_counts = df['gap_status'].value_counts()
    colors_list = [get_gap_color(status) for status in gap_counts.index]
    
    fig = go.Figure(data=[go.Pie(
        labels=gap_counts.index,
        values=gap_counts.values,
        marker=dict(
            colors=colors_list,
            line=dict(color=PROFESSIONAL_COLORS['bg_white'], width=3)
        ),
        textposition='inside',
        textinfo='label+percent',
        textfont=dict(size=12, color='white', family=FONT_FAMILY),
        hovertemplate='<b>%{label}</b><br>Count: %{value} categories<br>%{percent}<extra></extra>',
    )])
    
    fig.update_layout(
        title=dict(
            text='<b>Gap Severity Distribution</b>',
            font=dict(size=16, color=PROFESSIONAL_COLORS['text_dark'], family=FONT_FAMILY),
            x=0.5,
            xanchor='center'
        ),
        plot_bgcolor=PROFESSIONAL_COLORS['bg_white'],
        paper_bgcolor=PROFESSIONAL_COLORS['bg_white'],
        font=dict(family=FONT_FAMILY, size=12, color=PROFESSIONAL_COLORS['text_dark']),
        height=450,
        margin=dict(l=20, r=20, t=80, b=20),
    )
    
    return fig
