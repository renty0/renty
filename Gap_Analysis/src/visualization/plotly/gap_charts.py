import pandas as pd
import plotly.graph_objects as go
import plotly.express as px
from plotly.subplots import make_subplots
import numpy as np


COLORS = {
    'supply': '#3B82F6',      
    'demand': '#F97316',      
    'high_gap': '#DC2626', 
    'mild_gap': '#FBBF24',    
    'low_gap': '#10B981',     
    'neutral': '#9CA3AF',   
    'background': '#F9FAFB',  
}


def get_gap_color(gap_status: str) -> str:
    """Map gap status to color."""
    status_map = {
        'Critical Gap': COLORS['high_gap'],
        'High Gap': COLORS['high_gap'],
        'Moderate Gap': COLORS['mild_gap'],
        'Low Gap': COLORS['low_gap'],
    }
    return status_map.get(gap_status, COLORS['neutral'])


def create_supply_demand_bar_chart(summary_df: pd.DataFrame, 
                                   sort_by: str = 'gap_score') -> go.Figure:
    """
    Create side-by-side bar chart comparing supply and demand.
    
    Args:
        summary_df: Clean gap summary DataFrame
        sort_by: Column to sort by ('gap_score', 'demand', 'supply')
    
    Returns:
        Plotly Figure object
    """
    df = summary_df.sort_values(sort_by, ascending=False).copy()
    
    fig = go.Figure()
    
    fig.add_trace(go.Bar(
        x=df['category'],
        y=df['supply'],
        name='Supply (Listings)',
        marker=dict(color=COLORS['supply']),
        hovertemplate='<b>%{x}</b><br>Supply: %{y}<extra></extra>',
    ))
    
    fig.add_trace(go.Bar(
        x=df['category'],
        y=df['demand'],
        name='Demand (Searches)',
        marker=dict(color=COLORS['demand']),
        hovertemplate='<b>%{x}</b><br>Demand: %{y}<extra></extra>',
    ))
    
    fig.update_layout(
        title=dict(
            text='<b>Supply vs Demand by Category</b>',
            font=dict(size=18, color='#111827'),
        ),
        barmode='group',
        xaxis_title='Category',
        yaxis_title='Count',
        hovermode='x unified',
        plot_bgcolor=COLORS['background'],
        paper_bgcolor='white',
        font=dict(family='Inter, sans-serif', size=12, color='#374151'),
        height=500,
        showlegend=True,
        legend=dict(x=1.02, y=1, xanchor='left', yanchor='top'),
    )
    
    fig.update_xaxes(showgrid=False, linecolor='#E5E7EB', linewidth=1)
    fig.update_yaxes(gridcolor='#E5E7EB', linecolor='#E5E7EB', linewidth=1)
    
    return fig


def create_gap_score_bar_chart(summary_df: pd.DataFrame) -> go.Figure:
    """
    Create horizontal bar chart showing gap scores with color-coded severity.
    
    Args:
        summary_df: Clean gap summary DataFrame
    
    Returns:
        Plotly Figure object
    """
    df = summary_df.sort_values('gap_score', ascending=True).copy()
    
    colors = [get_gap_color(status) for status in df['gap_status']]
    
    fig = go.Figure()
    
    fig.add_trace(go.Bar(
        y=df['category'],
        x=df['gap_score'],
        orientation='h',
        marker=dict(color=colors, line=dict(width=1, color='white')),
        text=df['gap_score'].apply(lambda x: f'{x:.1f}'),
        textposition='outside',
        hovertemplate='<b>%{y}</b><br>Gap Score: %{x:.2f}<br>Status: %{customdata}<extra></extra>',
        customdata=df['gap_status'],
    ))
    
    top_3_indices = summary_df.nlargest(3, 'gap_score').index
    fig.add_annotation(
        text=' Top 3 Highest Gaps',
        xref='paper', yref='paper',
        x=0.02, y=0.98,
        showarrow=False,
        font=dict(size=11, color='#DC2626'),
        bgcolor='rgba(220, 38, 38, 0.1)',
        bordercolor='#DC2626',
        borderwidth=1,
        borderpad=4,
    )
    
    fig.update_layout(
        title=dict(
            text='<b>Gap Score by Category (Severity-Coded)</b>',
            font=dict(size=18, color='#111827'),
        ),
        xaxis_title='Gap Score',
        yaxis_title='Category',
        hovermode='y',
        plot_bgcolor=COLORS['background'],
        paper_bgcolor='white',
        font=dict(family='Inter, sans-serif', size=12, color='#374151'),
        height=500,
        showlegend=False,
    )
    
    fig.update_xaxes(showgrid=True, gridcolor='#E5E7EB', linecolor='#E5E7EB', linewidth=1)
    fig.update_yaxes(showgrid=False, linecolor='#E5E7EB', linewidth=1)
    
    return fig


def create_gap_heatmap(summary_df: pd.DataFrame) -> go.Figure:
    df = summary_df.copy()
    
    def normalize_col(col):
        min_val = df[col].min()
        max_val = df[col].max()
        if max_val - min_val == 0:
            return [0.5] * len(df)
        return (df[col] - min_val) / (max_val - min_val)
    
    heatmap_data = pd.DataFrame({
        'Category': df['category'],
        'Supply': normalize_col('supply'),
        'Demand': normalize_col('demand'),
        'Gap Score': normalize_col('gap_score'),
    })
    
    z = heatmap_data[['Supply', 'Demand', 'Gap Score']].T.values
    x = heatmap_data['Category'].values
    y = ['Supply', 'Demand', 'Gap Score']
    
    fig = go.Figure(data=go.Heatmap(
        z=z,
        x=x,
        y=y,
        colorscale=[
            [0, '#10B981'],
            [0.5, '#FBBF24'],
            [1, '#DC2626']
        ],
        text=np.round(z, 2),
        texttemplate='%{text:.2f}',
        textfont=dict(size=10, family='Inter, sans-serif', color='white'),
        hovertemplate='<b>%{y}</b><br>%{x}<br>Normalized: %{z:.3f}<extra></extra>',
        colorbar=dict(
            title='<b>Normalized</b>',
            thickness=15,
            len=0.7,
            tickfont=dict(size=10)
        ),
        line=dict(color='white', width=2)
    ))
    
    fig.update_layout(
        title=dict(
            text='<b>Gap Analysis Heatmap (Normalized Metrics)</b>',
            font=dict(size=15, color=COLORS['text_dark'], family='Inter, sans-serif'),
            x=0.5,
            xanchor='center'
        ),
        xaxis=dict(
            title='Category',
            showgrid=False,
            linecolor=COLORS['border'],
            linewidth=1
        ),
        yaxis=dict(
            title='Metric',
            showgrid=False,
            linecolor=COLORS['border'],
            linewidth=1
        ),
        plot_bgcolor=COLORS['bg_white'],
        paper_bgcolor=COLORS['bg_white'],
        font=dict(family='Inter, sans-serif', size=11, color=COLORS['text_dark']),
        height=400,
        margin=dict(l=100, r=100, t=100, b=80),
    )
    
    return fig


def create_category_ranking_chart(summary_df: pd.DataFrame, top_n: int = 5) -> go.Figure:
    top_gaps = summary_df.nlargest(top_n, 'gap_score')
    bottom_gaps = summary_df.nsmallest(top_n, 'gap_score')
    
    fig = make_subplots(
        rows=1, cols=2,
        subplot_titles=(
            f'<b>Top {top_n} Under-Supplied</b>',
            f'<b>Bottom {top_n} (Balanced)</b>'
        ),
        specs=[[{'type': 'bar'}, {'type': 'bar'}]],
        horizontal_spacing=0.18,
    )
    
    fig.add_trace(
        go.Bar(
            y=top_gaps['category'],
            x=top_gaps['gap_score'],
            orientation='h',
            marker=dict(
                color=COLORS['critical'],
                opacity=0.85,
                line=dict(color='white', width=2)
            ),
            text=top_gaps['gap_score'].apply(lambda x: f'{x:.2f}'),
            textposition='outside',
            textfont=dict(size=10, family='Inter, sans-serif'),
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
                color=COLORS['success'],
                opacity=0.85,
                line=dict(color='white', width=2)
            ),
            text=bottom_gaps['gap_score'].apply(lambda x: f'{x:.2f}'),
            textposition='outside',
            textfont=dict(size=10, family='Inter, sans-serif'),
            hovertemplate='<b>%{y}</b><br>Gap: %{x:.2f}<extra></extra>',
            name='Low Gap',
        ),
        row=1, col=2,
    )
    
    fig.update_xaxes(
        title_text='Gap Score',
        gridcolor=COLORS['border'],
        linecolor=COLORS['border'],
        linewidth=1,
        row=1, col=1,
        showgrid=True
    )
    fig.update_xaxes(
        title_text='Gap Score',
        gridcolor=COLORS['border'],
        linecolor=COLORS['border'],
        linewidth=1,
        row=1, col=2,
        showgrid=True
    )
    
    fig.update_yaxes(
        showgrid=False,
        linecolor=COLORS['border'],
        linewidth=1,
        row=1, col=1
    )
    fig.update_yaxes(
        showgrid=False,
        linecolor=COLORS['border'],
        linewidth=1,
        row=1, col=2
    )
    
    fig.update_layout(
        title=dict(
            text='<b>Category Gap Rankings</b>',
            font=dict(size=15, color=COLORS['text_dark'], family='Inter, sans-serif'),
            x=0.5,
            xanchor='center'
        ),
        plot_bgcolor=COLORS['bg_light'],
        paper_bgcolor=COLORS['bg_white'],
        font=dict(family='Inter, sans-serif', size=11, color=COLORS['text_dark']),
        height=500,
        margin=dict(l=100, r=100, t=100, b=80),
        showlegend=False,
    )
    
    return fig


def create_gap_distribution_pie(summary_df: pd.DataFrame) -> go.Figure:
    gap_counts = summary_df['gap_status'].value_counts()
    
    status_colors = {
        'Critical Gap': COLORS['critical'],
        'High Gap': COLORS['warning'],
        'Moderate Gap': '#FBBF24',
        'Low Gap': COLORS['success'],
    }
    
    colors_list = [status_colors.get(status, COLORS['text_muted']) for status in gap_counts.index]
    
    fig = go.Figure(data=[go.Pie(
        labels=gap_counts.index,
        values=gap_counts.values,
        marker=dict(
            colors=colors_list,
            line=dict(color=COLORS['bg_white'], width=3)
        ),
        textposition='inside',
        textinfo='label+percent',
        textfont=dict(size=12, color='white', family='Inter, sans-serif', weight='bold'),
        hovertemplate='<b>%{label}</b><br>Count: %{value} categories<br>%{percent}<extra></extra>',
        pull=[0.05 if colors_list[i] == COLORS['critical'] else 0 for i in range(len(colors_list))]
    )])
    
    fig.update_layout(
        title=dict(
            text='<b>Distribution of Gap Severity Levels</b>',
            font=dict(size=15, color=COLORS['text_dark'], family='Inter, sans-serif'),
            x=0.5,
            xanchor='center'
        ),
        plot_bgcolor=COLORS['bg_white'],
        paper_bgcolor=COLORS['bg_white'],
        font=dict(family='Inter, sans-serif', size=12, color=COLORS['text_dark']),
        height=500,
        margin=dict(l=20, r=20, t=100, b=20),
        legend=dict(
            orientation='v',
            yanchor='middle',
            y=0.5,
            xanchor='left',
            x=1.05,
            bgcolor=f'rgba(255, 255, 255, 0.8)',
            bordercolor=COLORS['border'],
            borderwidth=1
        )
    )
    
    return fig
