<<<<<<< HEAD
# Gap Analysis Project - Complete Technical Documentation

## Project Overview

This project performs comprehensive **Supply-Demand Gap Analysis** for a rental business platform. It identifies product categories with supply shortages, analyzes demand patterns, and generates actionable insights for business optimization through an automated pipeline of notebooks and reusable Python modules.

---

## Project Structure

```
rently_2026/
├── data/
│   └── processed/
│       ├── Project Data.xlsx                    # Raw input (8 sheets)
│       ├── Cleaned_data.xlsx                    # After cleaning
│       └── Category_Supply_Demand_Analysis.xlsx # Supply-demand metrics
├── Gap_Analysis/
│   ├── notebooks/                               # Analysis pipeline (execute in order)
│   │   ├── DataUnderstandingAndExploration.ipynb
│   │   ├── DataCleaningAndMerging.ipynb
│   │   ├── ComputeCategoryLevelSupply&Demand.ipynb
│   │   ├── MOAZ_Define_Metrics_GapScore.ipynb
│   │   ├── GapScoreImplementation.ipynb
│   │   ├── VisualizationDraft.ipynb
│   │   ├── InterpretationAndInsights.ipynb
│   │   └── Monitoring_and_Action_Plan.ipynb
│   ├── src/                                     # Reusable Python modules
│   │   ├── __init__.py
│   │   ├── config.py
│   │   ├── data_loader.py
│   │   ├── data_quality.py
│   │   ├── data_statistics.py
│   │   ├── data_preview.py
│   │   ├── data_relationships.py
│   │   ├── data_db_model.py
│   │   ├── data_exporter.py
│   │   ├── supply_demand.py
│   │   ├── gap_score.py
│   │   ├── gap_visualizer.py
│   │   ├── gap_dashboard_builder.py
│   │   ├── plotly_interactive_charts.py
│   │   ├── plotly_gap_charts.py
│   │   ├── plotly_dashboard.py
│   │   ├── dashboard_builder.py
│   │   ├── chart_insights.py
│   │   ├── monitoring_engine.py
│   │   ├── monitoring_visualizations.py
│   │   └── action_planner.py
│   ├── results/                                 # All outputs
│   │   ├── charts/                              # Static PNG images
│   │   ├── reports/                             # Excel reports
│   │   ├── visualizations_subcategory/          # Interactive HTML + data
│   │   ├── insights/                            # Text insights
│   │   ├── monitoring_reports/                  # Weekly snapshots
│   │   └── monitoring_dashboards/               # Monitoring HTML
│   └── scripts/
│       └── install_requirements.sh
└── README.md
```

---

## Complete Data Pipeline Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PHASE 1: DATA PREPARATION                            │
└─────────────────────────────────────────────────────────────────────────────┘
                                      ↓
    [1. DataUnderstandingAndExploration.ipynb]
         INPUT: Project Data.xlsx (8 sheets)
         USES: data_loader.py, data_quality.py, data_relationships.py
         OUTPUTS:
           • Data structure analysis (console output)
           • Missing value visualizations (PNG heatmaps)
           • Database relationship diagram (output.dbml + PNG)
           • Statistical summaries (console)
         API USAGE: Not directly - exploratory only
                                      ↓
    [2. DataCleaningAndMerging.ipynb]
         INPUT: Project Data.xlsx
         USES: data_loader.py, data_quality.py, gender_guesser library
         PROCESSES:
           • Fill missing ProductColor → "Mixed"
           • Fill missing ProductStyle → "U" (Unisex)
           • Infer Gender from FirstName
           • Generate Prefix based on Gender + MaritalStatus
           • Convert date columns to datetime
         OUTPUTS:
           • Cleaned_data.xlsx (8 sheets, all clean)
         API USAGE: This is the master cleaned dataset
                                      ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                   PHASE 2: SUPPLY-DEMAND COMPUTATION                         │
└─────────────────────────────────────────────────────────────────────────────┘
                                      ↓
    [3. ComputeCategoryLevelSupply&Demand.ipynb]
         INPUT: Cleaned_data.xlsx
         USES: supply_demand.py, pandas, matplotlib, seaborn
         PROCESSES:
           • Merge products with categories
           • Compute category-level sales (demand)
           • Compute category-level returns (supply adjustment)
           • Calculate net demand = sales - returns
           • Generate monthly trends
         OUTPUTS:
           • Category_Supply_Demand_Analysis.xlsx
             - Sheet 1: Category Summary (4 categories)
             - Sheet 2: Monthly Trends (time series)
           • Visualizations (PNG): pie charts, bar charts, dashboards
         API USAGE: 
           - /api/categories → Category Summary sheet
           - /api/trends → Monthly Trends sheet
                                      ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                     PHASE 3: GAP SCORE CALCULATION                           │
└─────────────────────────────────────────────────────────────────────────────┘
                                      ↓
    [4. MOAZ_Define_Metrics_GapScore.ipynb]
         INPUT: Cleaned_data.xlsx
         USES: config.py (TARGET_MULTIPLIERS), gap_analysis.py
         PROCESSES:
           • Define business KPIs (revenue, orders, customers)
           • Calculate target values using multipliers
           • Compute gap percentages
           • Classify gaps: Excellent/Good/Moderate/Severe
         OUTPUTS:
           • Console output with classified metrics
           • Bar charts showing gap levels
         API USAGE: Not directly - defines methodology only
                                      ↓
    [5. GapScoreImplementation.ipynb]
         INPUT: Cleaned_data.xlsx
         USES: supply_demand.py, gap_score.py, gap_visualizer.py
         PROCESSES:
           • Compute supply metrics (unique products per category/subcategory)
           • Compute demand metrics (orders, quantity sold)
           • Calculate Gap Score = (demand + 1) / (supply + 1)
           • Normalize and classify gap levels (Low/Moderate/High/Critical)
           • Perform subcategory-level analysis (37 subcategories)
           • Perform territory-level analysis (by region/country)
         OUTPUTS:
           • comprehensive_gap_analysis.xlsx (4 sheets):
             - Category Gaps (4 main categories)
             - Subcategory Gaps (37 subcategories)
             - Territory Gaps (category × territory)
             - Detailed Gaps (subcategory × territory)
           • charts/ folder: gap_score_bar.png, supply_vs_demand.png, etc.
         API USAGE: PRIMARY DATA SOURCE
           - /api/gaps/categories → Category Gaps sheet
           - /api/gaps/subcategories → Subcategory Gaps sheet
           - /api/gaps/territories → Territory Gaps sheet
           - /api/gaps/detailed → Detailed Gaps sheet
                                      ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                  PHASE 4: VISUALIZATION & INSIGHTS                           │
└─────────────────────────────────────────────────────────────────────────────┘
                                      ↓
    [6. VisualizationDraft.ipynb]
         INPUT: Cleaned_data.xlsx
         USES: plotly_interactive_charts.py, dashboard_builder.py, 
               data_exporter.py, chart_insights.py
         PROCESSES:
           • Load and compute subcategory-level gaps
           • Create 5 interactive Plotly charts:
             1. Supply vs Demand comparison (dual y-axes)
             2. Gap severity analysis (color-coded bars)
             3. Normalized metrics heatmap (0-1 scale)
             4. Category rankings (top/bottom)
             5. Gap distribution pie chart
           • Generate KPI cards (avg gap, critical count, total categories)
           • Export data summaries (CSV + JSON)
         OUTPUTS:
           • results/visualizations_subcategory/
             - data/
               • subcategory_gap_summary.csv
               • subcategory_gap_summary.json
             - interactive/ (HTML files for web embedding)
               • 01_supply_vs_demand_subcategory.html
               • 02_gap_severity_subcategory.html
               • 03_gap_heatmap_subcategory.html
               • 04_subcategory_rankings.html
               • 05_gap_distribution_subcategory.html
             - images/ (PNG for reports)
               • 01_supply_vs_demand_subcategory.png
               • 02_gap_severity_subcategory.png
               • 03_gap_heatmap_subcategory.png
               • 04_subcategory_rankings.png
               • 05_gap_distribution_subcategory.png
             - insights_subcategory.txt
         API USAGE:
           - /api/visualizations/supply-demand → HTML file
           - /api/visualizations/severity → HTML file
           - /api/visualizations/heatmap → HTML file
           - /api/data/subcategory-summary → CSV/JSON
           - /api/insights/charts → insights_subcategory.txt
                                      ↓
    [7. InterpretationAndInsights.ipynb]
         INPUT: Cleaned_data.xlsx
         USES: chart_insights.py (generate_interpretation_and_insights)
         PROCESSES:
           • Compute subcategory gaps
           • Generate comprehensive business insights:
             - Executive summary
             - Top gaps analysis
             - User behavior insights
             - Gap severity breakdown
             - Business recommendations
             - Next steps
         OUTPUTS:
           • results/insights/interpretation_and_insights.txt
             (2000+ word comprehensive analysis)
         API USAGE:
           - /api/insights/interpretation → Full text analysis
           - /api/insights/recommendations → Extracted recommendations
                                      ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                  PHASE 5: MONITORING & ACTION PLANNING                       │
└─────────────────────────────────────────────────────────────────────────────┘
                                      ↓
    [8. Monitoring_and_Action_Plan.ipynb]
         INPUT: Cleaned_data.xlsx
         USES: monitoring_engine.py, action_planner.py, 
               monitoring_visualizations.py
         PROCESSES:
           • Compute current week gap scores
           • Save weekly snapshot (JSON + CSV)
           • Compare with previous week (if exists)
           • Identify categories needing attention
           • Calculate priority (High/Medium/Low)
           • Generate action plans:
             - Operational actions (immediate)
             - Strategic actions (medium-term)
             - Platform optimization
             - User engagement initiatives
           • Create monitoring visualizations
         OUTPUTS:
           • results/monitoring_reports/
             - snapshot_week_X_YYYY-MM-DD.json
             - snapshot_week_X_YYYY-MM-DD.csv
             - action_plan_week_X.json (structured data)
             - action_plan_week_X.txt (human-readable)
           • results/monitoring_dashboards/
             - 01_monitoring_kpis.html
             - 02_active_alerts.html
             - 03_supply_demand_balance.html
         API USAGE:
           - /api/monitoring/snapshot/latest → Latest snapshot JSON
           - /api/monitoring/kpis → KPI summary
           - /api/monitoring/alerts → Flagged categories
           - /api/actions/current-week → Action plan JSON
           - /api/actions/priorities → Priority-sorted actions
```

---

## Python Modules Reference

### Core Data Processing Modules

#### **config.py**
- **Purpose**: Central configuration (paths, constants)
- **Key Contents**:
  - `PROJECT_ROOT`, `DATA_DIR`, `RESULTS_DIR`
  - `TARGET_MULTIPLIERS` (for KPI gap calculation)
- **Used By**: All notebooks

#### **data_loader.py**
- **Purpose**: Load Excel files into DataFrames
- **Functions**:
  - `load_excel_sheets(file_path)` → dict of DataFrames
  - `summarize_excel_sheets(datasets)` → summary DataFrame
- **Used By**: Notebooks 1, 2, 4

#### **data_quality.py**
- **Purpose**: Missing value analysis
- **Functions**:
  - `print_missing_data(datasets)` → console output
  - `plot_missing_heatmaps(datasets)` → PNG heatmaps
  - `plot_missing_summary_bar(datasets)` → bar chart
- **Used By**: Notebooks 1, 2

#### **data_statistics.py**
- **Purpose**: Statistical analysis
- **Functions**:
  - `analyze_numerical_statistics(datasets)` → describe()
  - `analyze_categorical_distributions(datasets)` → value_counts()
- **Used By**: Notebook 1

#### **data_relationships.py**
- **Purpose**: Infer table relationships
- **Functions**:
  - `explore_structure(datasets)` → column analysis
  - `infer_relationships(datasets)` → foreign keys
- **Used By**: Notebook 1

#### **data_db_model.py**
- **Purpose**: Generate database diagrams
- **Functions**:
  - `generate_dbml(datasets, parent_mapping)` → output.dbml file
- **Used By**: Notebook 1

---

### Supply-Demand Computation Modules

#### **supply_demand.py**
- **Purpose**: Calculate supply and demand metrics
- **Functions**:
  - `compute_category_supply(sales, products)` → unique products per category
  - `compute_category_demand(sales)` → orders per category
  - `compute_subcategory_supply(sales, products)` → 37 subcategories
  - `compute_subcategory_demand(sales)` → subcategory orders
  - `compute_territory_demand(sales, territories)` → geographic analysis
  - `merge_supply_demand(supply, demand)` → unified DataFrame
- **Used By**: Notebooks 3, 5, 6, 7, 8
- **API Impact**: Core metric calculation

---

### Gap Score Calculation Modules

#### **gap_score.py**
- **Purpose**: Compute and classify gap scores
- **Functions**:
  - `compute_gap_score(df, demand_col, supply_col)` → gap_score = (demand+1)/(supply+1)
  - `normalize_gap_score(df)` → 0-1 scale
  - `classify_gap_level(df)` → Low/Moderate/High/Critical
  - `compute_demand_supply_ratio(df)` → supplementary metrics
  - `rank_categories_by_gap(df)` → sorted by severity
- **Used By**: Notebooks 5, 6, 7, 8
- **API Impact**: Primary gap calculation logic

---

### Visualization Modules

#### **gap_visualizer.py** (Matplotlib/Seaborn)
- **Purpose**: Static chart generation
- **Functions**:
  - `plot_gap_score_bar(df)` → horizontal bar chart
  - `plot_supply_vs_demand(df)` → grouped bar chart
  - `plot_gap_dashboard(df)` → comprehensive dashboard
  - `plot_subcategory_gap_heatmap(df)` → category × subcategory
  - `plot_territory_gap_analysis(df)` → geographic gaps
- **Used By**: Notebook 5
- **Output**: PNG files in results/charts/

#### **plotly_interactive_charts.py**
- **Purpose**: Interactive Plotly visualizations
- **Functions**:
  - `create_supply_demand_chart(df)` → dual y-axis bar chart
  - `create_gap_score_severity_chart(df)` → color-coded severity
  - `create_gap_heatmap(df)` → normalized metrics heatmap
  - `create_category_ranking_chart(df)` → top/bottom rankings
  - `create_gap_distribution_pie(df)` → severity distribution
- **Used By**: Notebook 6
- **Output**: HTML files (embeddable in web apps)

#### **plotly_gap_charts.py**
- **Purpose**: Additional Plotly chart types
- **Functions**: Similar to plotly_interactive_charts but with different styling
- **Used By**: Notebook 6

#### **plotly_dashboard.py**
- **Purpose**: KPI card components
- **Functions**:
  - `create_kpi_card(title, value)` → single metric card
  - `create_dashboard_kpi_section(kpis)` → 4-card layout
  - `export_chart_png(fig, filepath)` → PNG export
  - `export_chart_html(fig, filepath)` → HTML export
- **Used By**: Notebooks 6, 8

#### **dashboard_builder.py**
- **Purpose**: Comprehensive dashboard assembly
- **Functions**:
  - `calculate_kpis(df)` → KPI dictionary
  - `create_kpi_cards(kpis)` → Plotly indicator figures
  - `create_comprehensive_dashboard(...)` → multi-chart layout
- **Used By**: Notebook 6

#### **monitoring_visualizations.py**
- **Purpose**: Monitoring-specific charts
- **Functions**:
  - `create_monitoring_kpi_cards(kpis)` → gauge + indicators
  - `create_gap_trend_chart(historical_df)` → time series
  - `create_alert_table(flagged_df)` → priority table
  - `create_change_heatmap(historical_df)` → weekly changes
  - `create_supply_demand_balance_chart(df)` → grouped bars
- **Used By**: Notebook 8
- **Output**: HTML dashboards

---

### Insights & Analysis Modules

#### **chart_insights.py**
- **Purpose**: Generate textual insights from data
- **Functions**:
  - `generate_supply_demand_insight(df)` → single-line summary
  - `generate_severity_insight(df)` → critical gap summary
  - `generate_heatmap_insight(df)` → balanced categories
  - `generate_ranking_insight(df)` → top gap range
  - `generate_executive_summary(df)` → comprehensive dict
  - `generate_interpretation_and_insights(df)` → 2000+ word analysis
- **Used By**: Notebooks 6, 7
- **API Impact**: Text content for /api/insights/*

---

### Monitoring & Action Planning Modules

#### **monitoring_engine.py**
- **Purpose**: Weekly snapshot and change tracking
- **Classes**:
  - `MonitoringSnapshot`: Save/load weekly snapshots
    - `save_snapshot(gap_df, week_number)` → JSON + CSV
    - `load_latest_snapshot()` → DataFrame
  - `GapChangeAnalyzer`: Compare snapshots
    - `compute_gap_change(current, previous)` → change percentages
    - `identify_categories_needing_attention(df)` → flagged categories
- **Functions**:
  - `compute_kpis(gap_df)` → KPI dictionary
- **Used By**: Notebook 8
- **API Impact**: 
  - /api/monitoring/snapshot/* → Snapshot files
  - /api/monitoring/kpis → KPI data

#### **action_planner.py**
- **Purpose**: Generate actionable recommendations
- **Class**: `ActionPlanner`
  - `generate_operational_actions(category, gap_score)` → immediate actions
  - `generate_strategic_actions(category, gap_score)` → medium-term
  - `generate_platform_actions(category, gap_score)` → tech optimizations
  - `generate_user_engagement_actions(category, gap_score)` → engagement
  - `generate_category_action_plan(gap_df, week)` → complete plan dict
  - `export_action_plan_json(plan, week)` → JSON file
  - `export_action_plan_text(plan, week)` → TXT file
- **Used By**: Notebook 8
- **API Impact**:
  - /api/actions/current-week → JSON action plan
  - /api/actions/category/{name} → Category-specific actions

---

### Export & Utility Modules

#### **data_exporter.py**
- **Purpose**: Standardized export functions
- **Functions**:
  - `export_dataframe_to_files(df, dir, filename)` → CSV + JSON
  - `export_plotly_chart(fig, filepath, format)` → HTML or PNG
  - `export_insights_to_text(insights_dict, filepath)` → formatted TXT
- **Used By**: Notebooks 6, 7, 8

#### **gap_dashboard_builder.py**
- **Purpose**: Dashboard data preparation
- **Functions**:
  - `prepare_gap_summary(gap_df)` → clean summary DataFrame
  - `export_gap_summary(summary, output_dir)` → CSV + JSON
  - `get_kpi_metrics(summary)` → KPI dictionary
- **Used By**: Notebook 6

---

## Output Files for API Integration

### Primary Data Files (Query These)

```
results/reports/
└── comprehensive_gap_analysis.xlsx
    ├── Category Gaps        → /api/gaps/categories
    ├── Subcategory Gaps     → /api/gaps/subcategories
    ├── Territory Gaps       → /api/gaps/territories
    └── Detailed Gaps        → /api/gaps/detailed

results/visualizations_subcategory/data/
├── subcategory_gap_summary.csv   → /api/data/subcategory-summary
└── subcategory_gap_summary.json  → /api/data/subcategory-summary

results/monitoring_reports/
├── snapshot_week_X_YYYY-MM-DD.json → /api/monitoring/snapshot/latest
├── action_plan_week_X.json         → /api/actions/current-week
└── action_plan_week_X.txt          → /api/actions/readable
```

### Visualization Files (Serve Directly)

```
results/visualizations_subcategory/interactive/
├── 01_supply_vs_demand_subcategory.html  → /api/viz/supply-demand
├── 02_gap_severity_subcategory.html      → /api/viz/severity
├── 03_gap_heatmap_subcategory.html       → /api/viz/heatmap
├── 04_subcategory_rankings.html          → /api/viz/rankings
└── 05_gap_distribution_subcategory.html  → /api/viz/distribution

results/monitoring_dashboards/
├── 01_monitoring_kpis.html               → /api/monitoring/kpis-dashboard
├── 02_active_alerts.html                 → /api/monitoring/alerts-dashboard
└── 03_supply_demand_balance.html         → /api/monitoring/balance-dashboard
```

### Insight Files (Text Content)

```
results/insights/
└── interpretation_and_insights.txt  → /api/insights/interpretation

results/visualizations_subcategory/
└── insights_subcategory.txt         → /api/insights/charts
```

---

## Key Metrics Explained

### Gap Score Formula
```
Gap Score = (Total Demand + 1) / (Total Supply + 1)
```
- **Supply** = Number of unique product listings in category
- **Demand** = Total order quantity (or number of orders)
- **+1 adjustment** = Prevents division by zero
- **Higher score** = Greater supply shortage

### Gap Classification
- **Low Gap** (< 50): Balanced supply-demand
- **Moderate Gap** (50-100): Some supply shortage
- **High Gap** (100-200): Significant supply gap
- **Critical Gap** (> 200): Severe supply shortage

### KPI Definitions
- **Avg Gap Score**: Mean gap score across all categories
- **Critical Categories**: Count of categories with Critical/High gaps
- **Critical %**: Percentage of categories with severe gaps
- **Total Supply**: Sum of unique products across all categories
- **Total Demand**: Sum of all order quantities
- **Return Rate**: (Returns / Sales) × 100

---

## Weekly Monitoring Workflow

1. **Run Notebook 8** weekly
2. **Generates**:
   - New snapshot (JSON/CSV) with current gap scores
   - Comparison with previous week
   - List of categories with:
     - Gap increasing (needs attention)
     - Gap improving (positive trend)
     - Supply drops or demand spikes
   - Prioritized action plans (High/Medium/Low)
3. **API Endpoints Update**:
   - `/api/monitoring/snapshot/latest` → New snapshot
   - `/api/monitoring/alerts` → Updated alert list
   - `/api/actions/current-week` → New action plan

---

## Team Contributions

- **Hamza** - Notebooks 1, 5: Data exploration, gap score implementation, territory analysis
- **Ahmad** - Notebook 2: Data cleaning, missing value handling, type conversions
- **Moaz** - Notebooks 3, 4, 6, 7, 8: Supply-demand computation, KPI definition, visualizations, monitoring, action planning

---

## API Endpoint Recommendations

### Core Data Endpoints
```
GET /api/gaps/categories           → Category Gaps sheet (4 categories)
GET /api/gaps/subcategories        → Subcategory Gaps sheet (37 subcategories)
GET /api/gaps/territories          → Territory Gaps sheet
GET /api/gaps/category/{name}      → Single category details
GET /api/gaps/subcategory/{name}   → Single subcategory details
```

### Visualization Endpoints
```
GET /api/viz/supply-demand         → HTML: Supply vs Demand chart
GET /api/viz/severity              → HTML: Gap severity chart
GET /api/viz/heatmap               → HTML: Normalized metrics heatmap
GET /api/viz/rankings              → HTML: Top/bottom rankings
GET /api/viz/distribution          → HTML: Gap distribution pie
```

### Monitoring Endpoints
```
GET /api/monitoring/snapshot/latest        → Latest snapshot JSON
GET /api/monitoring/snapshot/{week}        → Specific week snapshot
GET /api/monitoring/kpis                   → Current KPIs
GET /api/monitoring/alerts                 → Flagged categories
GET /api/monitoring/trends                 → Historical gap trends
```

### Action Planning Endpoints
```
GET /api/actions/current-week              → Latest action plan JSON
GET /api/actions/category/{name}           → Category-specific actions
GET /api/actions/priorities                → Sorted by priority
```

### Insights Endpoints
```
GET /api/insights/interpretation           → Full 2000+ word analysis
GET /api/insights/recommendations          → Extracted recommendations
GET /api/insights/executive-summary        → Brief summary
GET /api/insights/charts                   → Chart-specific insights
```

### Data Export Endpoints
```
GET /api/data/subcategory-summary.csv      → CSV download
GET /api/data/subcategory-summary.json     → JSON download
GET /api/data/comprehensive-report.xlsx    → Full Excel report
```

---

## Module Import Examples

```python
# In your API backend:
from Gap_Analysis.src import (
    load_excel_sheets,           # Load data
    compute_subcategory_supply,  # Calculate supply
    compute_subcategory_demand,  # Calculate demand
    compute_gap_score,           # Calculate gaps
    classify_gap_level,          # Classify severity
    MonitoringSnapshot,          # Weekly tracking
    ActionPlanner,               # Generate actions
    create_supply_demand_chart,  # Create visualizations
    generate_interpretation_and_insights  # Generate insights
)

# Load and process data
datasets = load_excel_sheets('data/processed/Cleaned_data.xlsx')
supply = compute_subcategory_supply(datasets['Sales Data'], products_full)
demand = compute_subcategory_demand(sales_full)
gaps = compute_gap_score(merge_supply_demand(supply, demand))
gaps = classify_gap_level(gaps)

# Generate insights
insights = generate_interpretation_and_insights(gaps)

# Create action plan
planner = ActionPlanner()
actions = planner.generate_category_action_plan(gaps)
```

---

**Total Notebooks**: 8  
**Total Python Modules**: 21  
**Total Output Files**: 30+  
**API-Ready Outputs**: 15+ endpoints
=======
# Renty E-commerce Recommendation System

[![Python](https://img.shields.io/badge/Python-3.8%2B-blue.svg)](https://www.python.org/)
[![LightFM](https://img.shields.io/badge/LightFM-1.17-green.svg)](https://github.com/lyst/lightfm)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A comprehensive hybrid recommendation system built with LightFM for the Renty e-commerce platform. This system leverages both collaborative filtering and content-based approaches to deliver personalized product recommendations based on user demographics, purchase behavior, and product features.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Dataset](#dataset)
- [Architecture](#architecture)
- [Installation](#installation)
- [Usage](#usage)
- [Model Performance](#model-performance)
- [Project Structure](#project-structure)
- [Technical Details](#technical-details)
- [Future Improvements](#future-improvements)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## 🎯 Overview

The Renty E-commerce Recommendation System is designed to enhance user experience and increase sales by providing intelligent, personalized product recommendations. The system analyzes historical transaction data, user demographics, and product characteristics to predict items that customers are most likely to purchase.

### Key Highlights

- **Hybrid Approach**: Combines collaborative filtering with content-based filtering
- **Advanced Feature Engineering**: RFM-based customer segmentation, temporal features, and TF-IDF text features
- **Robust Performance**: Test AUC of 0.84+ with low overfitting (gap < 0.05)
- **Production Ready**: Includes model persistence and inference pipeline

## ✨ Features

### Model Features

- **User Features**
  - Demographics: Gender, Marital Status, Education Level, Occupation, Home Ownership
  - Income Segmentation: 6-level income brackets (VeryLow to Premium)
  - Family Structure: Children categories (NoChildren, OneChild, TwoChildren, ManyChildren)
  - Behavioral Metrics: Total orders, unique products purchased, average order quantity
  - Customer Segments: Bronze, Silver, Gold, Platinum (RFM-inspired)
  - Temporal Features: Season, day of week, weekend indicator

- **Item Features**
  - Product Categories: Extracted from model names
  - Popularity Metrics: 5-level percentile ranking (Niche to Viral)
  - Text Features: TF-IDF extracted from product descriptions (50 features)
  - Customer Reach: Unique customer count per product

### System Capabilities

- ✅ Personalized top-N recommendations
- ✅ Filtering of already-purchased items
- ✅ Real-time prediction for new users (cold-start handling)
- ✅ Comprehensive evaluation metrics (Precision@K, Recall@K, AUC)
- ✅ Hyperparameter optimization with regularization
- ✅ Model serialization for deployment

## 📊 Dataset

### Data Overview

- **Total Transactions**: 55,666 orders
- **Unique Users**: 17,293 customers
- **Unique Products**: 130 items
- **Date Range**: January 2020 - June 2022
- **Sparsity**: 97.52%

### Data Schema

| Column | Type | Description |
|--------|------|-------------|
| OrderDate | datetime64 | Date of purchase |
| StockDate | datetime64 | Date item was stocked |
| OrderNumber | object | Unique order identifier |
| ProductKey | int64 | Product identifier |
| CustomerKey | int64 | Customer identifier |
| TerritoryKey | int64 | Geographic territory |
| OrderLineItem | int64 | Line item number |
| OrderQuantity | int64 | Quantity ordered |
| ModelName | object | Product model name |
| ProductDescription | object | Product description text |
| MaritalStatus | object | Customer marital status |
| Gender | object | Customer gender |
| AnnualIncome | int64 | Annual income ($) |
| TotalChildren | int64 | Number of children |
| EducationLevel | object | Education level |
| Occupation | object | Customer occupation |
| HomeOwner | object | Home ownership status |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Data Preprocessing                        │
│  • Load Excel data                                           │
│  • Convert datetime columns                                  │
│  • Remove duplicates                                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              Advanced Feature Engineering                    │
│  • Temporal features (year, month, quarter, season)         │
│  • Income brackets & children categories                    │
│  • User engagement metrics (RFM-inspired)                   │
│  • Customer segmentation (Bronze/Silver/Gold/Platinum)      │
│  • Item popularity percentiles                               │
│  • MinMax scaling for numerical features                    │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              Text Feature Extraction (TF-IDF)               │
│  • Extract 50 features from product descriptions           │
│  • Use unigrams and bigrams                                 │
│  • Filter by min document frequency                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                LightFM Data Preparation                      │
│  • Build user-item interaction matrices                     │
│  • Create user feature matrix (17,293 × 17,330)            │
│  • Create item feature matrix (130 × 206)                   │
│  • Temporal train/test split (80/20)                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│         Hyperparameter Tuning & Model Training              │
│  • Grid search with regularization                          │
│  • WARP loss function (implicit feedback)                   │
│  • L2 regularization (item_alpha, user_alpha)              │
│  • Best params: 50 components, 0.05 learning rate          │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              Model Evaluation & Deployment                   │
│  • Precision@K, Recall@K, AUC metrics                       │
│  • Model persistence (pickle)                                │
│  • Recommendation generation API                             │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Installation

### Prerequisites

- Python 3.8 or higher
- pip package manager
- (Optional) Google Colab account for notebook execution

### Setup Instructions

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/renty-recommendation-system.git
cd renty-recommendation-system
```

2. **Create virtual environment** (recommended)

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**

```bash
pip install -r requirements.txt
```

### Required Packages

```
pandas>=1.3.0
numpy>=1.21.0
matplotlib>=3.4.0
seaborn>=0.11.0
scikit-learn>=1.0.0
scipy>=1.7.0
lightfm>=1.17
```

**Note**: The project uses a specific LightFM fork. Install with:

```bash
pip install git+https://github.com/daviddavo/lightfm
```

## 💻 Usage

### Quick Start

#### 1. Train the Model

```python
# Load and train the complete pipeline
from main import main

filepath = "path/to/GradProject_final_1.xlsx"
model, dataset, user_features, item_features, df, results = main(filepath)
```

#### 2. Generate Recommendations

```python
from recommendation_utils import get_recommendations

# Get recommendations for a specific user
user_id = 14574
recommendations = get_recommendations(
    model=model,
    user_id=user_id,
    dataset=dataset,
    user_features=user_features,
    item_features=item_features,
    df=df,
    n_recommendations=10,
    filter_already_purchased=True
)

print(recommendations)
```

#### 3. Load Pre-trained Model

```python
import pickle

def load_model_artifacts(filepath='renty_lightfm_model_artifacts.pkl'):
    with open(filepath, 'rb') as f:
        artifacts = pickle.load(f)
    return (artifacts['model'], 
            artifacts['dataset'], 
            artifacts['user_features'], 
            artifacts['item_features'])

# Load saved model
model, dataset, user_features, item_features = load_model_artifacts()
```

### Interactive Recommendation Interface

```python
# Get user input and generate recommendations
sample_user_id = int(input("Please enter a User ID: "))

get_recommendations_for_input_user(
    user_id_input=sample_user_id,
    model=loaded_model,
    dataset=loaded_dataset,
    user_features=loaded_user_features,
    item_features=loaded_item_features,
    df=df,
    n_recommendations=10
)
```

### Running the Jupyter Notebook

1. Open the notebook in Google Colab or Jupyter:

```bash
jupyter notebook Ecommerce-Recommendation-System_Renty_Ecommerce_v1.ipynb
```

2. Mount Google Drive (if using Colab):

```python
from google.colab import drive
drive.mount('/content/drive')
```

3. Update the filepath to your dataset location
4. Run all cells sequentially

## 📈 Model Performance

### Final Model Metrics

| Metric | Value | Interpretation |
|--------|-------|----------------|
| **Test AUC** | 0.8409 | Good ranking ability |
| **Precision@5** | 0.1505 | 15% of top-5 recommendations are relevant |
| **Precision@10** | 0.1205 | 12% of top-10 recommendations are relevant |
| **Precision@20** | 0.0868 | 9% of top-20 recommendations are relevant |
| **Recall@5** | 0.2698 | Captures 27% of relevant items in top-5 |
| **Recall@10** | 0.4393 | Captures 44% of relevant items in top-10 |
| **Recall@20** | 0.6402 | Captures 64% of relevant items in top-20 |
| **Overfitting Gap** | 0.0493 | Low overfitting, good generalization |

### Optimal Hyperparameters

```python
{
    'no_components': 50,
    'learning_rate': 0.05,
    'loss': 'warp',
    'item_alpha': 1e-05,  # L2 regularization for items
    'user_alpha': 1e-05,  # L2 regularization for users
    'epochs': 60
}
```

### Performance Comparison

The improved model significantly outperforms the baseline:

- **AUC improvement**: +12% (0.75 → 0.84)
- **Overfitting reduction**: -71% (0.17 → 0.05)
- **Precision@10**: Maintained competitive performance with better generalization


## 🔧 Technical Details

### Feature Engineering Pipeline

#### 1. Temporal Features
- **OrderYear, OrderMonth, OrderQuarter**: Capture temporal trends
- **DayOfWeek, IsWeekend**: Identify purchasing patterns
- **Season**: Spring, Summer, Fall, Winter categorization

#### 2. User Segmentation
```python
# RFM-inspired Customer Value Score
CustomerValueScore = (
    TotalOrders * 0.3 +
    UniqueProducts * 0.3 +
    (TotalQuantity / TotalQuantity.max()) * 100 * 0.4
)

# Segment into tiers
CustomerSegment = pd.qcut(CustomerValueScore, q=4, 
                          labels=['Bronze', 'Silver', 'Gold', 'Platinum'])
```

#### 3. Text Feature Extraction
```python
# TF-IDF Vectorization
tfidf = TfidfVectorizer(
    max_features=50,
    stop_words='english',
    ngram_range=(1, 2),
    min_df=2
)
```

### LightFM Model Configuration

#### Loss Function: WARP (Weighted Approximate-Rank Pairwise)
- Optimized for implicit feedback scenarios
- Focuses on ranking relevant items higher than irrelevant ones
- Particularly effective for top-N recommendations

#### Regularization Strategy
- **L2 Regularization**: Prevents overfitting on sparse data
- **Item Alpha (1e-05)**: Regularizes item feature embeddings
- **User Alpha (1e-05)**: Regularizes user feature embeddings

### Train/Test Split Strategy

**Temporal Split (80/20)**
- Training: First 80% of data chronologically (44,532 samples)
- Testing: Most recent 20% of data (11,134 samples)
- Simulates real-world scenario where model predicts future purchases

### Evaluation Methodology

```python
# Precision@K: Fraction of recommended items that are relevant
Precision@K = (Relevant items in top-K) / K

# Recall@K: Fraction of relevant items that are recommended
Recall@K = (Relevant items in top-K) / (Total relevant items)

# AUC: Area Under ROC Curve
# Measures the model's ability to rank relevant items higher
```

## 🔮 Future Improvements

### Short-term Enhancements
- [ ] Implement real-time recommendation API with Flask/FastAPI
- [ ] Add A/B testing framework for model evaluation
- [ ] Create recommendation diversity metrics
- [ ] Develop cold-start strategy for new users/items
- [ ] Add explainability features (why this recommendation?)

### Medium-term Goals
- [ ] Integrate deep learning approaches (Neural Collaborative Filtering)
- [ ] Implement session-based recommendations (RNN/Transformer)
- [ ] Add multi-objective optimization (relevance + diversity + serendipity)
- [ ] Create recommendation confidence scores
- [ ] Develop automated retraining pipeline

### Long-term Vision
- [ ] Build real-time streaming recommendation system
- [ ] Implement contextual bandits for online learning
- [ ] Add multi-modal features (images, reviews, ratings)
- [ ] Create recommendation explanation dashboard
- [ ] Develop cross-domain recommendation capabilities

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Contribution Guidelines

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow PEP 8 style guide for Python code
- Add docstrings to all functions and classes
- Include type hints where appropriate
- Write unit tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **LightFM Library**: For providing an excellent hybrid recommendation framework
- **Renty E-commerce**: For the dataset and use case
- **Team Members**: 
  - Abdulrahman (Data Analysis & EDA)
  - Yasser Ashraf (Model Development)
  - Moamen Ahmed (Model Evaluation)

## 📞 Contact

For questions or feedback, please reach out:

- **Email**: yasserashraf3142@gmail.com
- **LinkedIn**: [Yasser Ashraf](https://www.linkedin.com/in/yasserashraf/)

**⭐ If you find this project helpful, please consider giving it a star!**

Last Updated: November 2025
>>>>>>> development
