import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np
import os


def plot_gap_score_bar(df: pd.DataFrame, output_path: str = None):
    """Create bar chart showing gap scores by category."""
    df = df.copy()
    
    if 'NormalizedGapScore' not in df.columns:
        min_gap = df['GapScore'].min()
        max_gap = df['GapScore'].max()
        if max_gap - min_gap > 0:
            df['NormalizedGapScore'] = (df['GapScore'] - min_gap) / (max_gap - min_gap)
        else:
            df['NormalizedGapScore'] = 0.5
    
    fig, ax = plt.subplots(figsize=(10, 8))
    
    colors = plt.cm.RdYlGn_r(df['NormalizedGapScore'])
    
    bars = ax.barh(df['CategoryName'], df['GapScore'], color=colors)
    
    ax.set_xlabel('Gap Score', fontsize=12, fontweight='bold')
    ax.set_ylabel('Category', fontsize=12, fontweight='bold')
    ax.set_title('Supply-Demand Gap Score by Category', fontsize=14, fontweight='bold')
    ax.grid(axis='x', alpha=0.3, linestyle='--')
    
    ax.invert_yaxis()
    
    for i, (bar, score) in enumerate(zip(bars, df['GapScore'])):
        ax.text(score + (df['GapScore'].max() * 0.02), bar.get_y() + bar.get_height()/2, 
               f'{score:.1f}', va='center', fontsize=10, fontweight='bold')
    
    plt.tight_layout()
    
    if output_path:
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        plt.savefig(output_path, dpi=300, bbox_inches='tight')
    
    plt.show()


def plot_supply_vs_demand(df: pd.DataFrame, output_path: str = None):
    """Create grouped bar chart comparing supply and demand with dual y-axes (no scaling)."""
    df = df.copy()
    
    fig, ax1 = plt.subplots(figsize=(12, 7))
    
    x = np.arange(len(df))
    width = 0.35
    
    # Left y-axis: Supply (actual values)
    supply_bars = ax1.bar(x - width/2, df['UniqueProducts'], width, 
                         label='Supply (Unique Products)', color='#3498db', alpha=0.8)
    ax1.set_xlabel('Category', fontsize=12, fontweight='bold')
    ax1.set_ylabel('Supply (Unique Products)', fontsize=12, fontweight='bold', color='#3498db')
    ax1.tick_params(axis='y', labelcolor='#3498db')
    
    # Add data labels on supply bars
    for bar, value in zip(supply_bars, df['UniqueProducts']):
        ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 2, 
                f'{int(value)}', ha='center', va='bottom', fontsize=10, 
                fontweight='bold', color='#3498db')
    
    # Right y-axis: Demand (actual values - NO SCALING)
    ax2 = ax1.twinx()
    demand_bars = ax2.bar(x + width/2, df['TotalQuantitySold'], width, 
                         label='Demand (Total Sold)', color='#e74c3c', alpha=0.8)
    ax2.set_ylabel('Demand (Total Quantity Sold)', fontsize=12, fontweight='bold', color='#e74c3c')
    ax2.tick_params(axis='y', labelcolor='#e74c3c')
    
    # Add data labels on demand bars with actual values
    for bar, value in zip(demand_bars, df['TotalQuantitySold']):
        ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + (df['TotalQuantitySold'].max() * 0.01), 
                f'{int(value):,}', ha='center', va='bottom', fontsize=10, 
                fontweight='bold', color='#e74c3c')
    
    ax1.set_title('Supply vs Demand by Category (Actual Values)', fontsize=14, fontweight='bold')
    ax1.set_xticks(x)
    ax1.set_xticklabels(df['CategoryName'], rotation=45, ha='right')
    
    # Combined legend
    lines1, labels1 = ax1.get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    ax1.legend(lines1 + lines2, labels1 + labels2, loc='upper right')
    
    ax1.grid(axis='y', alpha=0.3, linestyle='--')
    
    plt.tight_layout()
    
    if output_path:
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        plt.savefig(output_path, dpi=300, bbox_inches='tight')
    
    plt.show()


def plot_gap_dashboard(df: pd.DataFrame, output_path: str = None):
    """Create comprehensive dashboard with multiple gap metrics."""
    df = df.copy()
    
    if 'NormalizedGapScore' not in df.columns:
        min_gap = df['GapScore'].min()
        max_gap = df['GapScore'].max()
        if max_gap - min_gap > 0:
            df['NormalizedGapScore'] = (df['GapScore'] - min_gap) / (max_gap - min_gap)
        else:
            df['NormalizedGapScore'] = 0.5
    
    fig = plt.figure(figsize=(16, 10))
    gs = fig.add_gridspec(3, 2, hspace=0.3, wspace=0.3)
    
    colors_palette = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12']
    
    ax1 = fig.add_subplot(gs[0, :])
    colors = plt.cm.RdYlGn_r(df['NormalizedGapScore'])
    ax1.barh(df['CategoryName'], df['GapScore'], color=colors)
    ax1.set_xlabel('Gap Score')
    ax1.set_title('Gap Score by Category', fontweight='bold', fontsize=12)
    ax1.invert_yaxis()
    ax1.grid(axis='x', alpha=0.3)
    
    ax2 = fig.add_subplot(gs[1, 0])
    ax2.bar(df['CategoryName'], df['UniqueProducts'], color=colors_palette[0], alpha=0.7)
    ax2.set_ylabel('Number of Products')
    ax2.set_title('Supply (Unique Products)', fontweight='bold', fontsize=12)
    ax2.tick_params(axis='x', rotation=45)
    ax2.grid(axis='y', alpha=0.3)
    
    ax3 = fig.add_subplot(gs[1, 1])
    ax3.bar(df['CategoryName'], df['TotalQuantitySold'], color=colors_palette[1], alpha=0.7)
    ax3.set_ylabel('Total Quantity Sold')
    ax3.set_title('Demand (Sales Volume)', fontweight='bold', fontsize=12)
    ax3.tick_params(axis='x', rotation=45)
    ax3.grid(axis='y', alpha=0.3)
    
    ax4 = fig.add_subplot(gs[2, 0])
    if 'GapLevel' in df.columns:
        gap_counts = df['GapLevel'].value_counts()
        ax4.pie(gap_counts.values, labels=gap_counts.index, autopct='%1.1f%%',
               colors=colors_palette, startangle=90)
        ax4.set_title('Gap Level Distribution', fontweight='bold', fontsize=12)
    else:
        ax4.text(0.5, 0.5, 'Gap Level\nNot Available', ha='center', va='center')
        ax4.axis('off')
    
    ax5 = fig.add_subplot(gs[2, 1])
    ax5.axis('off')
    
    highest_gap_idx = df['GapScore'].idxmax()
    lowest_gap_idx = df['GapScore'].idxmin()
    
    summary_text = f"""
    Key Metrics Summary
    
    Total Categories: {len(df)}
    
    Average Gap Score: {df['GapScore'].mean():.2f}
    
    Highest Gap: {df.loc[highest_gap_idx, 'CategoryName']}
    Score: {df.loc[highest_gap_idx, 'GapScore']:.2f}
    
    Lowest Gap: {df.loc[lowest_gap_idx, 'CategoryName']}
    Score: {df.loc[lowest_gap_idx, 'GapScore']:.2f}
    """
    
    if 'GapLevel' in df.columns:
        critical_count = len(df[df['GapLevel'] == 'Critical Gap'])
        summary_text += f"\n    Critical Gaps: {critical_count}"
    
    ax5.text(0.1, 0.5, summary_text, fontsize=11, verticalalignment='center',
            family='monospace', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.3))
    
    plt.suptitle('Supply-Demand Gap Analysis Dashboard', 
                fontsize=16, fontweight='bold', y=0.98)
    
    if output_path:
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        plt.savefig(output_path, dpi=300, bbox_inches='tight')
    
    plt.show()


def plot_gap_heatmap(monthly_df: pd.DataFrame, output_path: str = None):
    """Create heatmap showing gap scores over time."""
    pivot_data = monthly_df.pivot(index='CategoryName', columns='Month', values='GapScore')
    
    fig, ax = plt.subplots(figsize=(14, 6))
    
    sns.heatmap(pivot_data, annot=True, fmt='.1f', cmap='RdYlGn_r',
               cbar_kws={'label': 'Gap Score'}, linewidths=0.5, ax=ax)
    
    ax.set_title('Gap Score Trends Over Time', fontsize=14, fontweight='bold')
    ax.set_xlabel('Month', fontsize=12)
    ax.set_ylabel('Category', fontsize=12)
    
    plt.tight_layout()
    
    if output_path:
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        plt.savefig(output_path, dpi=300, bbox_inches='tight')
    
    plt.show()


def plot_subcategory_gap_heatmap(df: pd.DataFrame, output_path: str = None):
    """Create heatmap showing gap scores by category and subcategory."""
    pivot_data = df.pivot(index='SubcategoryName', columns='CategoryName', values='GapScore')
    
    fig, ax = plt.subplots(figsize=(12, 10))
    
    sns.heatmap(pivot_data, annot=True, fmt='.1f', cmap='RdYlGn_r',
               cbar_kws={'label': 'Gap Score'}, linewidths=0.5, ax=ax)
    
    ax.set_title('Gap Score by Category and Subcategory', fontsize=14, fontweight='bold')
    ax.set_xlabel('Category', fontsize=12)
    ax.set_ylabel('Subcategory', fontsize=12)
    
    plt.tight_layout()
    
    if output_path:
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        plt.savefig(output_path, dpi=300, bbox_inches='tight')
    
    plt.show()


def plot_territory_gap_analysis(df: pd.DataFrame, output_path: str = None):
    """Create visualization showing gap distribution across territories."""
    fig, axes = plt.subplots(2, 1, figsize=(14, 10))
    
    territory_gap = df.groupby(['Region', 'Country'])['GapScore'].mean().reset_index()
    territory_gap = territory_gap.sort_values('GapScore', ascending=False)
    
    colors = plt.cm.RdYlGn_r(territory_gap['GapScore'] / territory_gap['GapScore'].max())
    
    bars = axes[0].barh(territory_gap['Region'] + ' - ' + territory_gap['Country'], 
                        territory_gap['GapScore'], color=colors)
    axes[0].set_xlabel('Average Gap Score', fontsize=12, fontweight='bold')
    axes[0].set_ylabel('Territory', fontsize=12, fontweight='bold')
    axes[0].set_title('Average Gap Score by Territory', fontsize=14, fontweight='bold')
    axes[0].invert_yaxis()
    axes[0].grid(axis='x', alpha=0.3, linestyle='--')
    
    top_territories = territory_gap.head(3)
    
    for idx, territory in top_territories.iterrows():
        territory_data = df[(df['Region'] == territory['Region']) & 
                           (df['Country'] == territory['Country'])]
        territory_label = f"{territory['Region']} - {territory['Country']}"
        
        axes[1].plot(territory_data['CategoryName'], territory_data['GapScore'], 
                    marker='o', label=territory_label, linewidth=2)
    
    axes[1].set_xlabel('Category', fontsize=12, fontweight='bold')
    axes[1].set_ylabel('Gap Score', fontsize=12, fontweight='bold')
    axes[1].set_title('Gap Score by Category in Top 3 Territories', fontsize=14, fontweight='bold')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    axes[1].tick_params(axis='x', rotation=45)
    
    plt.tight_layout()
    
    if output_path:
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        plt.savefig(output_path, dpi=300, bbox_inches='tight')
    
    plt.show()


def plot_gap_by_region_category(df: pd.DataFrame, output_path: str = None):
    """Create heatmap showing gap scores by region and category."""
    pivot_data = df.pivot_table(index='Region', columns='CategoryName', 
                                 values='GapScore', aggfunc='mean')
    
    fig, ax = plt.subplots(figsize=(12, 8))
    
    sns.heatmap(pivot_data, annot=True, fmt='.1f', cmap='RdYlGn_r',
               cbar_kws={'label': 'Gap Score'}, linewidths=0.5, ax=ax)
    
    ax.set_title('Gap Score Heatmap: Region vs Category', fontsize=14, fontweight='bold')
    ax.set_xlabel('Category', fontsize=12)
    ax.set_ylabel('Region', fontsize=12)
    
    plt.tight_layout()
    
    if output_path:
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        plt.savefig(output_path, dpi=300, bbox_inches='tight')
    
    plt.show()


def plot_top_gaps_summary(subcategory_gaps: pd.DataFrame, territory_gaps: pd.DataFrame, 
                          top_n: int = 10, output_path: str = None):
    """Create summary visualization of top gaps."""
    fig = plt.figure(figsize=(16, 10))
    gs = fig.add_gridspec(2, 2, hspace=0.3, wspace=0.3)
    
    ax1 = fig.add_subplot(gs[0, 0])
    top_subcat = subcategory_gaps.nlargest(top_n, 'GapScore')
    colors1 = plt.cm.RdYlGn_r(top_subcat['NormalizedGapScore'])
    ax1.barh(range(len(top_subcat)), top_subcat['GapScore'], color=colors1)
    ax1.set_yticks(range(len(top_subcat)))
    ax1.set_yticklabels(top_subcat['SubcategoryName'], fontsize=9)
    ax1.set_xlabel('Gap Score')
    ax1.set_title(f'Top {top_n} Subcategories by Gap Score', fontweight='bold')
    ax1.invert_yaxis()
    ax1.grid(axis='x', alpha=0.3)
    
    ax2 = fig.add_subplot(gs[0, 1])
    territory_avg = territory_gaps.groupby(['Region', 'Country'])['GapScore'].mean().reset_index()
    territory_avg = territory_avg.nlargest(top_n, 'GapScore')
    territory_avg['Label'] = territory_avg['Region'] + '\n' + territory_avg['Country']
    
    ax2.bar(range(len(territory_avg)), territory_avg['GapScore'], color='#e74c3c')
    ax2.set_xticks(range(len(territory_avg)))
    ax2.set_xticklabels(territory_avg['Label'], rotation=45, ha='right', fontsize=8)
    ax2.set_ylabel('Average Gap Score')
    ax2.set_title(f'Top {top_n} Territories by Gap Score', fontweight='bold')
    ax2.grid(axis='y', alpha=0.3)
    
    ax3 = fig.add_subplot(gs[1, 0])
    category_gaps = subcategory_gaps.groupby('CategoryName')['GapScore'].agg(['mean', 'max', 'min'])
    
    x = range(len(category_gaps))
    ax3.bar(x, category_gaps['mean'], color='#3498db', alpha=0.7, label='Average')
    ax3.errorbar(x, category_gaps['mean'], 
                yerr=[category_gaps['mean'] - category_gaps['min'], 
                      category_gaps['max'] - category_gaps['mean']],
                fmt='none', color='black', capsize=5, label='Min-Max Range')
    ax3.set_xticks(x)
    ax3.set_xticklabels(category_gaps.index, rotation=45, ha='right')
    ax3.set_ylabel('Gap Score')
    ax3.set_title('Gap Score Distribution by Category', fontweight='bold')
    ax3.legend()
    ax3.grid(axis='y', alpha=0.3)
    
    ax4 = fig.add_subplot(gs[1, 1])
    ax4.axis('off')
    
    highest_subcat = subcategory_gaps.loc[subcategory_gaps['GapScore'].idxmax()]
    highest_territory = territory_avg.iloc[0]
    
    summary_text = f"""
    KEY GAP INSIGHTS
    
    SUBCATEGORY ANALYSIS:
    Highest Gap: {highest_subcat['SubcategoryName']}
      Category: {highest_subcat['CategoryName']}
      Gap Score: {highest_subcat['GapScore']:.2f}
      Supply: {int(highest_subcat['UniqueProducts'])} products
      Demand: {int(highest_subcat['TotalQuantitySold'])} units
    
    TERRITORY ANALYSIS:
    Highest Gap Territory:
      {highest_territory['Region']} - {highest_territory['Country']}
      Avg Gap Score: {highest_territory['GapScore']:.2f}
    
    RECOMMENDATIONS:
    1. Prioritize supply increase in top gap
       subcategories
    2. Target marketing in high-gap territories
    3. Investigate supply chain bottlenecks
    4. Consider regional product preferences
    """
    
    ax4.text(0.1, 0.5, summary_text, fontsize=10, verticalalignment='center',
            family='monospace', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.3))
    
    plt.suptitle('Gap Analysis Summary: Subcategories & Territories', 
                fontsize=16, fontweight='bold', y=0.98)
    
    if output_path:
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        plt.savefig(output_path, dpi=300, bbox_inches='tight')
    
    plt.show()
