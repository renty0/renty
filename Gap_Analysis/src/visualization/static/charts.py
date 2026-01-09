import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots


def create_supply_demand_interactive(df, sort_by='gap_score'):
    """
    Interactive supply vs demand bar chart with proper scaling.
    """
    df_sorted = df.sort_values(sort_by, ascending=False)
    
    fig = go.Figure()
    
    fig.add_trace(go.Bar(
        x=df_sorted['category'],
        y=df_sorted['supply'],
        name='Supply (Listings)',
        marker_color='#3B82F6',
        hovertemplate='<b>%{x}</b><br>Supply: %{y:,.0f}<extra></extra>'
    ))
    
    fig.add_trace(go.Bar(
        x=df_sorted['category'],
        y=df_sorted['demand'],
        name='Demand (Orders)',
        marker_color='#F97316',
        hovertemplate='<b>%{x}</b><br>Demand: %{y:,.0f}<extra></extra>'
    ))
    
    fig.update_layout(
        title='Supply vs Demand by Category',
        xaxis_title='Category',
        yaxis_title='Count',
        barmode='group',
        hovermode='x unified',
        height=500,
        plot_bgcolor='#F9FAFB',
        paper_bgcolor='white',
        font=dict(family='Inter, sans-serif', size=12, color='#374151'),
        showlegend=True,
    )
    
    fig.update_yaxes(showgrid=True, gridcolor='#E5E7EB')
    
    return fig


def create_gap_severity_interactive(df):
    """
    Interactive horizontal bar chart with color-coded severity levels.
    """
    df_sorted = df.sort_values('gap_score', ascending=True)
    
    color_map = {
        'Critical Gap': '#DC2626',
        'High Gap': '#F59E0B',
        'Moderate Gap': '#FBBF24',
        'Low Gap': '#10B981'
    }
    
    colors = [color_map.get(status, '#9CA3AF') for status in df_sorted['gap_status']]
    
    fig = go.Figure(data=[
        go.Bar(
            y=df_sorted['category'],
            x=df_sorted['gap_score'],
            orientation='h',
            marker_color=colors,
            text=df_sorted['gap_score'].round(2),
            textposition='outside',
            hovertemplate='<b>%{y}</b><br>Gap Score: %{x:.2f}<br>Status: %{customdata}<extra></extra>',
            customdata=df_sorted['gap_status']
        )
    ])
    
    fig.update_layout(
        title='Gap Score Severity by Category',
        xaxis_title='Gap Score',
        yaxis_title='Category',
        height=500,
        plot_bgcolor='#F9FAFB',
        paper_bgcolor='white',
        font=dict(family='Inter, sans-serif', size=12, color='#374151'),
        showlegend=False,
    )
    
    fig.update_xaxes(showgrid=True, gridcolor='#E5E7EB')
    
    return fig


def create_heatmap_interactive(df):
    """
    Interactive normalized metrics heatmap.
    """
    heatmap_data = df[['supply', 'demand', 'gap_score']].T
    
    # Normalize each row independently for better visualization
    heatmap_normalized = (heatmap_data - heatmap_data.min(axis=1).values.reshape(-1, 1)) / \
                         (heatmap_data.max(axis=1).values.reshape(-1, 1) - heatmap_data.min(axis=1).values.reshape(-1, 1) + 1e-6)
    
    fig = go.Figure(data=go.Heatmap(
        z=heatmap_normalized.values,
        y=['Supply', 'Demand', 'Gap Score'],
        x=df['category'].values,
        colorscale='RdYlGn_r',
        hovertemplate='Category: %{x}<br>Metric: %{y}<br>Normalized Value: %{z:.2f}<extra></extra>',
        colorbar=dict(title='Normalized Value')
    ))
    
    fig.update_layout(
        title='Normalized Metrics Heatmap',
        xaxis_title='Category',
        yaxis_title='Metric',
        height=400,
        plot_bgcolor='#F9FAFB',
        paper_bgcolor='white',
        font=dict(family='Inter, sans-serif', size=12, color='#374151'),
    )
    
    return fig


def create_rankings_interactive(df, top_n=5):
    """
    Interactive top and bottom category rankings.
    """
    top_n_df = df.nlargest(top_n, 'gap_score')
    bottom_n_df = df.nsmallest(top_n, 'gap_score')
    
    ranking_df = pd.concat([top_n_df, bottom_n_df])
    ranking_df['rank_type'] = ['Top Gap'] * len(top_n_df) + ['Well-Balanced'] * len(bottom_n_df)
    
    colors = ['#DC2626' if t == 'Top Gap' else '#10B981' for t in ranking_df['rank_type']]
    
    fig = go.Figure(data=[
        go.Bar(
            y=ranking_df['category'],
            x=ranking_df['gap_score'],
            orientation='h',
            marker_color=colors,
            text=ranking_df['gap_score'].round(2),
            textposition='outside',
            hovertemplate='<b>%{y}</b><br>Gap Score: %{x:.2f}<br>Type: %{customdata}<extra></extra>',
            customdata=ranking_df['rank_type']
        )
    ])
    
    fig.update_layout(
        title='Category Rankings: Highest & Lowest Gaps',
        xaxis_title='Gap Score',
        yaxis_title='Category',
        height=500,
        plot_bgcolor='#F9FAFB',
        paper_bgcolor='white',
        font=dict(family='Inter, sans-serif', size=12, color='#374151'),
        showlegend=False,
    )
    
    fig.update_xaxes(showgrid=True, gridcolor='#E5E7EB')
    
    return fig


def create_distribution_interactive(df):
    """
    Interactive pie chart of gap distribution.
    """
    gap_counts = df['gap_status'].value_counts()
    
    color_map = {
        'Critical Gap': '#DC2626',
        'High Gap': '#F59E0B',
        'Moderate Gap': '#FBBF24',
        'Low Gap': '#10B981'
    }
    
    colors = [color_map.get(status, '#9CA3AF') for status in gap_counts.index]
    
    fig = go.Figure(data=[go.Pie(
        labels=gap_counts.index,
        values=gap_counts.values,
        marker=dict(colors=colors),
        hovertemplate='<b>%{label}</b><br>Count: %{value} categories<br>Percentage: %{percent}<extra></extra>'
    )])
    
    fig.update_layout(
        title='Gap Level Distribution',
        height=500,
        plot_bgcolor='#F9FAFB',
        paper_bgcolor='white',
        font=dict(family='Inter, sans-serif', size=12, color='#374151'),
    )
    
    return fig


def create_comprehensive_dashboard(summary_df, kpis):
    """
    Comprehensive 6-panel interactive dashboard.
    """
    df_sorted = summary_df.sort_values('gap_score', ascending=False)
    
    dashboard = make_subplots(
        rows=3, cols=2,
        subplot_titles=(
            'Supply vs Demand',
            'Gap Score Severity',
            'Gap Distribution',
            'Normalized Metrics',
            'Category Rankings',
            'Summary Statistics'
        ),
        specs=[
            [{'type': 'bar'}, {'type': 'bar'}],
            [{'type': 'pie'}, {'type': 'heatmap'}],
            [{'type': 'bar'}, {'type': 'table'}],
        ],
        vertical_spacing=0.12,
        horizontal_spacing=0.12,
    )
    
    # Row 1: Supply vs Demand
    dashboard.add_trace(
        go.Bar(x=df_sorted['category'], y=df_sorted['supply'], name='Supply', 
               marker_color='#3B82F6', hovertemplate='%{x}<br>Supply: %{y:,.0f}<extra></extra>'),
        row=1, col=1
    )
    dashboard.add_trace(
        go.Bar(x=df_sorted['category'], y=df_sorted['demand'], name='Demand',
               marker_color='#F97316', hovertemplate='%{x}<br>Demand: %{y:,.0f}<extra></extra>'),
        row=1, col=1
    )
    
    # Row 1, Col 2: Gap Score Severity
    colors_gap = ['#DC2626' if s == 'Critical Gap' else '#FBBF24' if s == 'Moderate Gap' else '#10B981' 
                  for s in df_sorted['gap_status']]
    dashboard.add_trace(
        go.Bar(y=df_sorted['category'], x=df_sorted['gap_score'], orientation='h',
               marker_color=colors_gap, name='Gap Score',
               hovertemplate='%{y}<br>Gap: %{x:.2f}<extra></extra>'),
        row=1, col=2
    )
    
    # Row 2, Col 1: Pie Chart
    gap_counts = summary_df['gap_status'].value_counts()
    dashboard.add_trace(
        go.Pie(labels=gap_counts.index, values=gap_counts.values, name='Gap Levels'),
        row=2, col=1
    )
    
    # Row 2, Col 2: Heatmap
    heatmap_vals = summary_df[['supply', 'demand', 'gap_score']].values.T
    dashboard.add_trace(
        go.Heatmap(z=heatmap_vals, y=['Supply', 'Demand', 'Gap'], x=summary_df['category'],
                   colorscale='RdYlGn_r', name='Metrics'),
        row=2, col=2
    )
    
    # Row 3, Col 1: Rankings
    top_2 = summary_df.nlargest(2, 'gap_score')
    bottom_2 = summary_df.nsmallest(2, 'gap_score')
    ranking_data = pd.concat([top_2, bottom_2])
    dashboard.add_trace(
        go.Bar(y=ranking_data['category'], x=ranking_data['gap_score'], orientation='h',
               marker_color=['#DC2626', '#DC2626', '#10B981', '#10B981'],
               name='Ranking', hovertemplate='%{y}<br>Gap: %{x:.2f}<extra></extra>'),
        row=3, col=1
    )
    
    # Row 3, Col 2: Summary Table
    summary_table = summary_df[['category', 'supply', 'demand', 'gap_score', 'gap_status']].head(6)
    dashboard.add_trace(
        go.Table(
            header=dict(values=['<b>Category</b>', '<b>Supply</b>', '<b>Demand</b>', '<b>Gap Score</b>', '<b>Status</b>'],
                       fill_color='#3B82F6', font=dict(color='white', size=11)),
            cells=dict(values=[summary_table['category'], 
                              summary_table['supply'].astype(int),
                              summary_table['demand'].astype(int),
                              summary_table['gap_score'].round(2),
                              summary_table['gap_status']],
                      fill_color='#F9FAFB', font=dict(size=10)),
        ),
        row=3, col=2
    )
    
    dashboard.update_layout(
        title_text='<b>Supply-Demand Gap Analysis Dashboard</b>',
        height=1400,
        showlegend=True,
        plot_bgcolor='#F9FAFB',
        paper_bgcolor='white',
        font=dict(family='Inter, sans-serif', size=11, color='#374151'),
    )
    
    dashboard.update_xaxes(showgrid=True, gridcolor='#E5E7EB')
    dashboard.update_yaxes(showgrid=True, gridcolor='#E5E7EB')
    
    return dashboard
