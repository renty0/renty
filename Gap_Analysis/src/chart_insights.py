import pandas as pd


def generate_supply_demand_insight(df: pd.DataFrame) -> str:
    """Generate insight text for supply vs demand chart."""
    highest_gap = df.loc[df['gap_score'].idxmax()]
    supply_demand_ratio = highest_gap['demand'] / (highest_gap['supply'] + 1)
    
    return f"{highest_gap['category']}: {int(highest_gap['demand'])} demand vs {int(highest_gap['supply'])} supply (Ratio: {supply_demand_ratio:.1f}:1)"


def generate_severity_insight(df: pd.DataFrame) -> str:
    """Generate insight text for gap severity analysis."""
    df_temp = df.copy()
    df_temp["gap_score_adj"] = df_temp["gap_score"].replace(0, 0.01)
    highest_gap = df_temp.loc[df_temp["gap_score_adj"].idxmax()]
    critical_high = len(df[df["gap_status"].isin(["Critical Gap", "High Gap"])])
    
    return f"{critical_high}/{len(df)} critical/high ({(critical_high/len(df)*100):.1f}%). Worst: {highest_gap['category']} ({highest_gap['gap_score']:.2f})"


def generate_heatmap_insight(df: pd.DataFrame) -> str:
    """Generate insight text for normalized metrics heatmap."""
    lowest_gap = df.loc[df['gap_score'].idxmin()]
    return f"Best balanced: {lowest_gap['category']} (gap: {lowest_gap['gap_score']:.2f})"


def generate_ranking_insight(df: pd.DataFrame, top_n: int = 5) -> str:
    """Generate insight text for category rankings."""
    top_categories = df.nlargest(top_n, 'gap_score')
    return f"Top {top_n} gaps: {top_categories['gap_score'].min():.2f} to {top_categories['gap_score'].max():.2f}"


def generate_executive_summary(df: pd.DataFrame) -> dict:
    """Generate comprehensive executive summary."""
    highest_gap = df.loc[df['gap_score'].idxmax()]
    lowest_gap = df.loc[df['gap_score'].idxmin()]
    critical_count = len(df[df['gap_status'] == 'Critical Gap'])
    high_count = len(df[df['gap_status'] == 'High Gap'])
    
    return {
        'critical_gaps': {
            'count': critical_count,
            'most_severe': highest_gap['category'],
            'gap_score': highest_gap['gap_score'],
            'supply': int(highest_gap['supply']),
            'demand': int(highest_gap['demand']),
            'gap_pct': highest_gap['gap_pct']
        },
        'balanced_categories': {
            'example': lowest_gap['category'],
            'gap_score': lowest_gap['gap_score'],
            'supply': int(lowest_gap['supply']),
            'demand': int(lowest_gap['demand'])
        },
        'overall_metrics': {
            'total_categories': len(df),
            'avg_gap_score': df['gap_score'].mean(),
            'critical_high_count': critical_count + high_count,
            'critical_high_pct': (critical_count + high_count) / len(df) * 100,
            'total_supply': int(df['supply'].sum()),
            'total_demand': int(df['demand'].sum())
        },
        'recommendations': {
            'immediate': [
                f"Expand supply: {highest_gap['category']}",
                "Launch campaigns in high-gap categories",
                "Investigate supply chain bottlenecks"
            ],
            'medium_term': [
                "Demand management for balanced categories",
                "Category-specific growth strategies",
                "Monitor monthly gap trends"
            ],
            'strategic': [
                "Optimize pricing in high-gap categories",
                "Expand product offerings",
                "Create category-specific KPIs"
            ]
        }
    }
