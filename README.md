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
