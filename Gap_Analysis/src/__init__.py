__version__ = "1.0.0"
__author__ = "Hamza"

# Data processing modules
from .data.loader import load_excel_sheets, summarize_excel_sheets
from .data.quality import print_missing_data, plot_missing_heatmaps, plot_missing_summary_bar
from .data.statistics import analyze_numerical_statistics, analyze_categorical_distributions
from .data.preview import preview_all_datasets, check_duplicates
from .data.relationships import explore_structure, infer_relationships

# Analysis modules
from .analysis.supply_demand import (compute_category_supply, compute_category_demand, merge_supply_demand,
                            compute_subcategory_supply, compute_subcategory_demand,
                            compute_territory_demand, compute_subcategory_territory_demand)
from .analysis.gap_score import (compute_gap_score, normalize_gap_score, classify_gap_level, 
                        compute_demand_supply_ratio, rank_categories_by_gap)

# Visualization modules - Static
from .visualization.static.gap_visualizer import (plot_gap_score_bar, plot_supply_vs_demand, 
                             plot_gap_dashboard, plot_gap_heatmap,
                             plot_subcategory_gap_heatmap, plot_territory_gap_analysis,
                             plot_gap_by_region_category, plot_top_gaps_summary)

# Visualization modules - Dashboards
from .visualization.dashboards.gap_builder import prepare_gap_summary, export_gap_summary, get_kpi_metrics

# Visualization modules - Plotly
from .visualization.plotly.gap_charts import (
    create_supply_demand_bar_chart,
    create_gap_score_bar_chart,
    create_gap_heatmap,
    create_category_ranking_chart,
    create_gap_distribution_pie,
)
from .visualization.plotly.dashboard import (
    create_kpi_card,
    create_dashboard_kpi_section,
    export_chart_png,
    export_chart_html,
)

# Monitoring modules
from .monitoring.engine import (
    MonitoringSnapshot,
    GapChangeAnalyzer,
    compute_kpis
)
from .monitoring.action_planner import ActionPlanner
from .monitoring.visualizations import (
    create_monitoring_kpi_cards,
    create_gap_trend_chart,
    create_alert_table,
    create_change_heatmap,
    create_supply_demand_balance_chart
)


__all__ = [
    "load_excel_sheets",
    "summarize_excel_sheets",
    "print_missing_data",
    "plot_missing_heatmaps",
    "plot_missing_summary_bar",
    "analyze_numerical_statistics",
    "analyze_categorical_distributions",
    "preview_all_datasets",
    "check_duplicates",
    "explore_structure",
    "infer_relationships",
    "compute_category_supply",
    "compute_category_demand",
    "compute_subcategory_supply",
    "compute_subcategory_demand",
    "compute_territory_demand",
    "compute_subcategory_territory_demand",
    "merge_supply_demand",
    "compute_gap_score",
    "normalize_gap_score",
    "classify_gap_level",
    "compute_demand_supply_ratio",
    "rank_categories_by_gap",
    "plot_gap_score_bar",
    "plot_supply_vs_demand",
    "plot_gap_dashboard",
    "plot_gap_heatmap",
    "plot_subcategory_gap_heatmap",
    "plot_territory_gap_analysis",
    "plot_gap_by_region_category",
    "plot_top_gaps_summary",
    "prepare_gap_summary",
    "export_gap_summary",
    "get_kpi_metrics",
    "create_supply_demand_bar_chart",
    "create_gap_score_bar_chart",
    "create_gap_heatmap",
    "create_category_ranking_chart",
    "create_gap_distribution_pie",
    "create_kpi_card",
    "create_dashboard_kpi_section",
    "export_chart_png",
    "export_chart_html",
    "MonitoringSnapshot",
    "GapChangeAnalyzer",
    "compute_kpis",
    "ActionPlanner",
    "create_monitoring_kpi_cards",
    "create_gap_trend_chart",
    "create_alert_table",
    "create_change_heatmap",
    "create_supply_demand_balance_chart",
]
