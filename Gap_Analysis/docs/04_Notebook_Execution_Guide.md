# Notebook Execution Guide

## Execution Order

Execute notebooks in this exact order:

### 1. 01_DataUnderstandingAndExploration.ipynb
**Purpose**: Load and examine all 8 CSV datasets, analyze data structure, relationships, and quality.

**Input**: 
- `data/processed/Project Data.xlsx` (8 sheets)

**Output**:
- `results/db/output.dbml` - Database relationship diagram
- `results/db/dataset RD.png` - ERD visualization  
- Missing value heatmaps (displayed in notebook)
- Statistical summaries (displayed in notebook)

**Estimated Time**: 5-10 minutes

---

### 2. 02_DataCleaningAndMerging.ipynb
**Purpose**: Handle missing values, infer customer gender, generate title prefixes, and export cleaned dataset.

**Input**: 
- `data/processed/Project Data.xlsx`

**Output**:
- `data/processed/Cleaned_data.xlsx` (8 sheets, all clean)
- Data quality statistics (displayed in notebook)

**Key Operations**:
- Fill missing ProductColor → "Mixed"
- Fill missing ProductStyle → "U" (Unisex)
- Infer Gender from FirstName
- Generate Prefix based on Gender + MaritalStatus

**Estimated Time**: 3-5 minutes

---

### 3. 03_ComputeCategoryLevelSupplyAndDemand.ipynb
**Purpose**: Calculate supply and demand metrics at category level and generate monthly trends.

**Input**: 
- `data/processed/Cleaned_data.xlsx`

**Output**:
- `results/reports/Category_Supply_Demand_Analysis.xlsx`
  - Sheet 1: Category Summary (4 categories)
  - Sheet 2: Monthly Trends (time series)
- Trend visualizations (PNG charts displayed in notebook)

**Estimated Time**: 3-5 minutes

---

### 4. 04_DefineMetrics_GapScore.ipynb
**Purpose**: Define business KPIs and establish Gap Score formula and classification criteria.

**Input**: 
- `data/processed/Cleaned_data.xlsx`

**Output**:
- **Gap Score Formula**: `(Demand + 1) / (Supply + 1)`
- **Classification Criteria**:
  - Low Gap: < 50
  - Moderate Gap: 50-100
  - High Gap: 100-200
  - Critical Gap: > 200
- KPI calculations (displayed in notebook)

**Estimated Time**: 3-5 minutes

---

### 5. 05_GapScoreImplementation.ipynb
**Purpose**: Compute gap scores at category, subcategory, and territory levels.

**Input**: 
- `data/processed/Cleaned_data.xlsx`

**Output**:
- `results/reports/comprehensive_gap_analysis.xlsx` (4 sheets):
  - Category Gaps (4 main categories)
  - Subcategory Gaps (37 subcategories)
  - Territory Gaps (category × territory)
  - Detailed Gaps (subcategory × territory)
- `results/charts/` - PNG visualizations:
  - gap_score_bar.png
  - supply_vs_demand.png
  - gap_dashboard.png
  - subcategory_gap_heatmap.png
  - territory_gap_analysis.png
  - region_category_heatmap.png

**Estimated Time**: 5-8 minutes

---

### 6. 06_VisualizationDraft.ipynb
**Purpose**: Create interactive Plotly charts and export visualization data.

**Input**: 
- `data/processed/Cleaned_data.xlsx`

**Output**:
- `results/visualizations_subcategory/interactive/` - 5 HTML charts:
  - 01_supply_vs_demand_subcategory.html
  - 02_gap_severity_subcategory.html
  - 03_gap_heatmap_subcategory.html
  - 04_subcategory_rankings.html
  - 05_gap_distribution_subcategory.html
- `results/visualizations_subcategory/images/` - 5 PNG exports
- `results/visualizations_subcategory/data/`:
  - subcategory_gap_summary.csv
  - subcategory_gap_summary.json
- `results/visualizations_subcategory/insights_subcategory.txt`

**Estimated Time**: 5-10 minutes

---

### 7. 07_InterpretationAndInsights.ipynb
**Purpose**: Analyze gap scores and generate comprehensive business insights.

**Input**: 
- `data/processed/Cleaned_data.xlsx`

**Output**:
- `results/insights/interpretation_and_insights.txt` (2000+ word analysis)
  - Executive summary
  - Top gaps analysis
  - User behavior insights
  - Gap severity breakdown
  - Business recommendations
  - Next steps

**Estimated Time**: 3-5 minutes

---

### 8. 08_MonitoringAndActionPlan.ipynb
**Purpose**: Implement weekly monitoring system and generate action plans.

**Input**: 
- `data/processed/Cleaned_data.xlsx`

**Output**:
- `results/monitoring_reports/`:
  - snapshot_week_X_YYYY-MM-DD.json
  - snapshot_week_X_YYYY-MM-DD.csv
  - action_plan_week_X.json (structured data)
  - action_plan_week_X.txt (human-readable)
- `results/monitoring_dashboards/`:
  - 01_monitoring_kpis.html
  - 02_active_alerts.html
  - 03_supply_demand_balance.html

**Estimated Time**: 5-8 minutes

---

## Total Execution Time
**Approximately 30-45 minutes** for all 8 notebooks

---

## Prerequisites

1. **Python Environment**: Python 3.8+
2. **Required Packages**: Install from `requirements.txt`
   ```bash
   pip install -r requirements.txt
   ```
3. **Data**: Ensure `data/processed/Project Data.xlsx` exists

---

## Import Statement Updates

After src/ folder reorganization, notebooks use:

```python
# Old imports (before reorganization)
from src.data_loader import load_excel_sheets
from src.gap_score import compute_gap_score

# New imports (after reorganization)
from src.data.loader import load_excel_sheets
from src.analysis.gap_score import compute_gap_score
```

All import paths have been updated in the notebooks to reflect the new organized structure.

---

## Troubleshooting

- **ModuleNotFoundError**: Ensure you're running notebooks from the project root directory
- **Missing data file**: Check that `data/processed/Project Data.xlsx` exists
- **Import errors**: Verify all packages are installed: `pip install -r requirements.txt`

---

## Notes

- Notebooks build on each other sequentially
- Each notebook documents its outputs clearly in markdown cells
- Visualizations can be viewed directly in notebooks or exported files
- Interactive HTML charts can be opened in any web browser
