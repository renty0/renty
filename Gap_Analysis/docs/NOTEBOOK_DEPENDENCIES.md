# Gap Analysis - Notebook Dependencies

**Quick Reference** | Updated: 2026-01-01

## Notebook Dependencies

**01 - Data Understanding & Exploration**
- Data exploration & quality assessment
- Uses: `data.loader`, `data.quality`, `data.preview`, `data.relationships`, `data.statistics`, `data.db_model`

**02 - Data Cleaning & Merging**
- Clean & merge datasets
- Uses: `data.loader`, `data.quality`

**03 - Supply & Demand Computation**
- Compute category-level metrics
- Uses: `data.loader`, `analysis.supply_demand`

**04 - Define Metrics (Gap Score)**
- Gap score methodology definition
- Uses: `data.loader`, `analysis.supply_demand`

**05 - Gap Score Implementation**
- Implement gap score calculations
- Uses: `data.loader`, `analysis.supply_demand`, `analysis.gap_score`, `visualization.static.gap_visualizer`

**06 - Visualization Draft**
- Interactive dashboards & charts
- Uses: `data.loader`, `analysis.*`, `visualization.plotly.interactive_charts`, `visualization.dashboards.builder`, `insights.chart_insights`, `data.exporter`

**07 - Interpretation & Insights**
- Generate recommendations
- Uses: `data.loader`, `analysis.supply_demand`, `analysis.gap_score`, `insights.chart_insights`

**08 - Monitoring & Action Plan**
- Action plans & alerts
- Uses: `data.loader`, `analysis.*`, `monitoring.engine`, `monitoring.action_planner`, `monitoring.visualizations`, `data.exporter`

---

## Module Structure

```
src/
├── data/               # loader, quality, preview, relationships, statistics, db_model, exporter
├── analysis/           # supply_demand, gap_score
├── visualization/      # static/, plotly/, dashboards/
├── insights/           # chart_insights
├── monitoring/         # engine, action_planner, visualizations
└── utils/              # export_manager
```

## Output Locations

```
results/
├── db/                 # DBML schemas
├── Summary/            # Excel reports
├── data/               # CSV/JSON exports
├── charts/             # HTML/PNG visualizations
└── monitoring_reports/ # Weekly snapshots & action plans
```

---

## Recent Fixes (2026-01-01)

✅ Import paths updated after reorganization  
✅ Output directories now save to `results/` (not `src/results/`)  
✅ Auto-create missing directories  
✅ Embedded visualization helpers in `data.quality`

**Note:** Restart Jupyter kernel after updates!
