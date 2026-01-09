import pandas as pd


def generate_supply_demand_insight(df: pd.DataFrame) -> str:
    """Generate insight text for supply vs demand chart."""
    highest_gap = df.loc[df['gap_score'].idxmax()]
    supply_demand_ratio = highest_gap['demand'] / (highest_gap['supply'] + 1)
    
    return f"{highest_gap['category']}: {int(highest_gap['demand'])} demand vs {int(highest_gap['supply'])} supply (ratio: {supply_demand_ratio:.1f}:1)"


def generate_severity_insight(df: pd.DataFrame) -> str:
    """Generate insight text for gap severity analysis."""
    df_temp = df.copy()
    df_temp["gap_score_adj"] = df_temp["gap_score"].replace(0, 0.01)
    highest_gap = df_temp.loc[df_temp["gap_score_adj"].idxmax()]
    critical_high = len(df[df["gap_status"].isin(["Critical Gap", "High Gap"])])
    
    return f"{critical_high}/{len(df)} critical/high ({(critical_high/len(df)*100):.1f}%). worst: {highest_gap['category']} ({highest_gap['gap_score']:.2f})"


def generate_heatmap_insight(df: pd.DataFrame) -> str:
    """Generate insight text for normalized metrics heatmap."""
    lowest_gap = df.loc[df['gap_score'].idxmin()]
    return f"best balanced: {lowest_gap['category']} (gap: {lowest_gap['gap_score']:.2f})"


def generate_ranking_insight(df: pd.DataFrame, top_n: int = 5) -> str:
    """Generate insight text for category rankings."""
    top_categories = df.nlargest(top_n, 'gap_score')
    return f"top {top_n} gaps: {top_categories['gap_score'].min():.2f} to {top_categories['gap_score'].max():.2f}"


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
                f"expand supply: {highest_gap['category']}",
                "launch campaigns in high-gap categories",
                "investigate supply chain bottlenecks"
            ],
            'medium_term': [
                "demand management for balanced categories",
                "category-specific growth strategies",
                "monitor monthly gap trends"
            ],
            'strategic': [
                "optimize pricing in high-gap categories",
                "expand product offerings",
                "create category-specific kpis"
            ]
        }
    }


def generate_interpretation_and_insights(df: pd.DataFrame) -> str:
    """
    generate business insights from gap analysis.
    takes gap summary dataframe and returns formatted insight text.
    """
    highest = df.loc[df['gap_score'].idxmax()]
    lowest = df.loc[df['gap_score'].idxmin()]
    severity_counts = df['gap_status'].value_counts()
    top5 = df.nlargest(5, 'gap_score')
    
    critical_high_count = severity_counts.get('Critical Gap', 0) + severity_counts.get('High Gap', 0)
    critical_pct = (critical_high_count / len(df)) * 100
    
    insight_text = f"""
gap analysis interpretation and insights
{'=' * 80}

executive summary
{'-' * 80}

the analysis examined {len(df)} product categories to identify supply-demand imbalances.
{critical_high_count} categories ({critical_pct:.1f}%) show critical or high gaps requiring immediate action.

most critical shortage:
- category: {highest['category']}
- gap score: {highest['gap_score']:.2f}
- supply: {int(highest['supply'])} products
- demand: {int(highest['demand'])} orders
- gap: {highest['gap_pct']:.1f}%

best balanced category:
- category: {lowest['category']}
- gap score: {lowest['gap_score']:.2f}
- supply: {int(lowest['supply'])} products
- demand: {int(lowest['demand'])} orders


interpretation
{'-' * 80}

the gap score represents the ratio of demand to supply. higher scores indicate
categories where customer orders significantly exceed available product listings.

for {highest['category']}, the gap score of {highest['gap_score']:.2f} means demand is
{highest['gap_score']:.1f}x higher than supply. this represents potential revenue loss
and customer dissatisfaction due to limited product availability.

categories with high gaps show consistent user searches and orders but insufficient
inventory. this indicates strong market demand that the platform cannot currently fulfill.

in contrast, {lowest['category']} shows a balanced supply-demand ratio with a gap score
of {lowest['gap_score']:.2f}, indicating adequate product listings relative to customer interest.


user behavior insights
{'-' * 80}

based on the supply and demand data:

1. users consistently search for and order products in categories with limited supply
   - top 5 categories by gap account for a disproportionate share of unmet demand

2. categories with gap scores above 100 show demand outpacing supply by 100x or more
   - {len(df[df['gap_score'] > 100])} categories fall into this range

3. several categories show low gap scores, indicating either:
   - adequate supply meeting current demand
   - low user interest despite available inventory


gap severity breakdown
{'-' * 80}
"""
    
    for status, count in severity_counts.items():
        pct = (count / len(df)) * 100
        insight_text += f"\n{status}: {count} categories ({pct:.1f}%)"
    
    insight_text += f"""


top 5 categories requiring attention
{'-' * 80}
"""
    
    for idx, row in top5.iterrows():
        insight_text += f"""
{row['category']}
  gap score: {row['gap_score']:.2f}
  supply: {int(row['supply'])} products | demand: {int(row['demand'])} orders
  status: {row['gap_status']}
"""
    
    insight_text += f"""

business recommendations
{'-' * 80}

based on the gap analysis, the following actions are recommended:

1. expand supply in high-gap categories
   focus on onboarding more lenders in {highest['category']} and other
   critical shortage categories to close the supply gap

2. incentivize product uploads in shortage areas
   create targeted campaigns to encourage lenders to list products in
   categories with gaps above 50

3. optimize marketing for balanced categories
   categories with low gaps have adequate supply and can support increased
   demand through marketing campaigns

4. implement monthly gap monitoring
   track gap scores over time to identify emerging shortages and measure
   the impact of supply expansion efforts

5. investigate user search patterns
   analyze search queries in high-gap categories to understand specific
   product types users are seeking but cannot find


next steps
{'-' * 80}

this analysis provides the foundation for strategic decisions about:
- supplier recruitment priorities
- inventory expansion targets
- marketing budget allocation
- product category development

regular monitoring of these metrics will help maintain supply-demand balance
and maximize platform revenue potential.

{'=' * 80}
"""
    
    return insight_text
