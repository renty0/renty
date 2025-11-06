__version__ = "1.0.0"
__author__ = "Hamza"

from .data_loader import load_excel_sheets, summarize_excel_sheets
from .data_quality import print_missing_data, plot_missing_heatmaps, plot_missing_summary_bar
from .data_statistics import analyze_numerical_statistics, analyze_categorical_distributions
from .data_preview import preview_all_datasets, check_duplicates
from .data_relationships import explore_structure, infer_relationships
from .supply_demand import (compute_category_supply, compute_category_demand, merge_supply_demand,
                            compute_subcategory_supply, compute_subcategory_demand,
                            compute_territory_demand, compute_subcategory_territory_demand)
from .gap_score import (compute_gap_score, normalize_gap_score, classify_gap_level, 
                        compute_demand_supply_ratio, rank_categories_by_gap)
from .gap_visualizer import (plot_gap_score_bar, plot_supply_vs_demand, 
                             plot_gap_dashboard, plot_gap_heatmap,
                             plot_subcategory_gap_heatmap, plot_territory_gap_analysis,
                             plot_gap_by_region_category, plot_top_gaps_summary)

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
]
