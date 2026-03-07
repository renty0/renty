# Supply-Demand Gap Analysis: Comprehensive Technical Report

**Project:** Rently 2026 Platform Optimization  
**Version:** 4.0  
**Date:** December 04, 2025  
**Prepared By:** Gap Analysis Data Team  

---

## 1. Executive Summary

The **Supply-Demand Gap Analysis** project is a sophisticated data engineering and analytics solution designed to optimize the Rently 2026 rental platform. Its primary mission is to identify, quantify, and visualize imbalances between product supply (listings) and customer demand (orders). By leveraging historical transaction data, the system calculates a "Gap Score" for every product category, subcategory, and geographic territory.

This report details the technical architecture, code implementation, and analytical workflow of the project. It demonstrates how the system operates as a cohesive unit—integrating raw data processing, statistical modeling, interactive visualization, and automated monitoring—to deliver actionable business intelligence.

---

## 2. System Architecture

The project follows a modular architecture that separates **orchestration** (Jupyter Notebooks) from **core logic** (Python modules). This design ensures reproducibility, scalability, and ease of maintenance.

### 2.1 Directory Structure

The project is organized into a clear hierarchy:

```
rently_2026/
├── data/                        # Data storage
│   └── processed/               # Cleaned and intermediate datasets
├── Gap_Analysis/
│   ├── notebooks/               # Orchestration layer (The Workflow)
│   ├── src/                     # Core logic layer (The Engine)
│   ├── results/                 # Output layer (The Intelligence)
│   └── scripts/                 # Utility scripts (Reports, Setup)
└── README.md                    # Documentation entry point
```

### 2.2 The "One Unit" Philosophy

The system is designed to function as a single, integrated unit. 
- **The `src` folder** acts as the library or API. It contains stateless, reusable functions that perform specific tasks (e.g., "calculate gap score", "generate chart").
- **The `notebooks` folder** acts as the controller. It calls functions from `src` in a specific sequence to execute the end-to-end analysis pipeline.

This separation allows the complex logic to be hidden within `src`, keeping the notebooks clean and focused on the analytical narrative.

---

## 3. Detailed Component Analysis (`src` Folder)

The `src` directory contains the analytical engine of the project. Below is a detailed breakdown of the key modules and their specific roles within the system.

### 3.1 Data Processing Layer

#### `data_loader.py`
**Role:** The Gateway.  
**Functionality:** Handles the ingestion of raw Excel data. It includes robust error handling to manage missing files and provides summary statistics (row counts, missing values) immediately upon loading. This ensures that downstream processes always receive valid dataframe objects.

#### `data_quality.py`
**Role:** The Validator.  
**Functionality:** Scans datasets for anomalies. It generates heatmaps to visualize missing data patterns, allowing analysts to decide between imputation (filling values) or removal. It is critical for ensuring the integrity of the "Gap Score" calculation.

#### `data_relationships.py`
**Role:** The Mapper.  
**Functionality:** Infers the schema of the database. It analyzes column names to detect foreign key relationships (e.g., linking `ProductKey` in Sales to `ProductKey` in Products). This enables the automatic merging of disparate tables into a unified analytical dataset.

### 3.2 Computation Layer (The Core)

#### `supply_demand.py`
**Role:** The Calculator.  
**Functionality:** This module computes the fundamental numerators and denominators for the analysis.
- **Supply Calculation:** Counts unique `ProductKey` entries per Category/Subcategory.
- **Demand Calculation:** Aggregates `OrderQuantity` and counts unique `OrderNumber`s.
- **Territory Logic:** Maps sales to geographic regions to enable location-based analysis.

#### `gap_score.py`
**Role:** The Scorer.  
**Functionality:** Implements the mathematical heart of the project.
- **Formula:** `Gap Score = (Total Demand + 1) / (Total Supply + 1)`
- **Normalization:** Scales scores to a 0-1 range for comparative heatmaps.
- **Classification:** Categorizes scores into actionable buckets (Low, Moderate, High, Critical) based on business thresholds.

### 3.3 Visualization Layer

#### `gap_visualizer.py`
**Role:** Static Reporting.  
**Functionality:** Uses Matplotlib and Seaborn to generate high-quality static images (PNGs). These are used for PDF reports and slide decks where interactivity is not required.

#### `plotly_interactive_charts.py`
**Role:** Dynamic Exploration.  
**Functionality:** Generates HTML-based interactive charts. These allow stakeholders to zoom, hover for details, and filter data. This module powers the "Self-Service" aspect of the results, enabling users to answer their own questions.

### 3.4 Monitoring & Action Layer

#### `monitoring_engine.py`
**Role:** The Watchdog.  
**Functionality:** Enables temporal analysis.
- **Snapshots:** Saves the state of the system (Gap Scores) at a specific point in time.
- **Change Detection:** Compares the current snapshot with the previous week's to calculate `% Change`.
- **Alerting:** Flags categories that have crossed critical thresholds or are trending negatively.

#### `action_planner.py`
**Role:** The Strategist.  
**Functionality:** Translates numerical scores into English recommendations.
- **Rule-Based Logic:** "If Gap > 5 AND Supply < Demand * 0.3, THEN Recommend Supplier Recruitment."
- **Output:** Generates structured Action Plans (JSON/Text) that can be directly used by operations teams.

---

## 4. Workflow Walkthrough (`notebooks` Folder)

The analysis is executed sequentially through 8 notebooks. Each notebook represents a distinct phase of the data pipeline.

### Phase 1: Data Preparation

**1. DataUnderstandingAndExploration.ipynb**
- **Input:** Raw `Project Data.xlsx`.
- **Process:** Profiling data types, distributions, and quality issues.
- **Output:** Knowledge about schema and cleaning requirements.

**2. DataCleaningAndMerging.ipynb**
- **Input:** Raw Data.
- **Process:** Imputing missing values (e.g., setting missing colors to "Mixed"), standardizing dates, and performing the "Big Merge" to create a single master dataset.
- **Output:** `Cleaned_data.xlsx` (The Gold Standard dataset).

### Phase 2: Core Analysis

**3. ComputeCategoryLevelSupply&Demand.ipynb**
- **Input:** `Cleaned_data.xlsx`.
- **Process:** Aggregating transactions to calculate raw Supply and Demand totals.
- **Output:** `Category_Supply_Demand_Analysis.xlsx`.

**4. MOAZ_Define_Metrics_GapScore.ipynb**
- **Input:** Business Goals.
- **Process:** Defining the "Target Multipliers" (e.g., we want supply to be 1.2x demand).
- **Output:** Configuration parameters for the scoring engine.

**5. GapScoreImplementation.ipynb**
- **Input:** Supply/Demand Metrics + Config.
- **Process:** Applying the Gap Score formula across all dimensions (Category, Subcategory, Territory).
- **Output:** `comprehensive_gap_analysis.xlsx` (The Master Report).

### Phase 3: Visualization & Insights

**6. VisualizationDraft.ipynb**
- **Input:** Gap Scores.
- **Process:** Generating the suite of Plotly dashboards.
- **Output:** HTML files in `results/visualizations`.

**7. InterpretationAndInsights.ipynb**
- **Input:** Gap Scores.
- **Process:** Running the `chart_insights.py` logic to generate textual summaries.
- **Output:** `interpretation_and_insights.txt`.

### Phase 4: Continuous Improvement

**8. Monitoring_and_Action_Plan.ipynb**
- **Input:** Current Gap Scores + Historical Snapshots.
- **Process:** Calculating week-over-week changes and generating the weekly Action Plan.
- **Output:** `results/monitoring_reports/action_plan_week_X.json`.

---

## 5. Outputs & Results Explained (`results` Folder)

The output directory is structured to serve different consumers of the data.

### 5.1 `results/reports/`
**Target Audience:** Data Analysts & Executives.
- **`comprehensive_gap_analysis.xlsx`**: The most detailed view. Contains raw numbers, calculated scores, and rankings for every single subcategory and territory.

### 5.2 `results/visualizations/`
**Target Audience:** Product Managers & Stakeholders.
- **`*.html` Files**: Standalone interactive dashboards. These can be opened in any web browser without Python. They provide a "Supply vs Demand" view that makes the gap visually obvious.

### 5.3 `results/monitoring_reports/`
**Target Audience:** Operations Teams.
- **`action_plan_week_X.txt`**: A readable to-do list. It tells the team exactly which categories need more supply (Lender Acquisition) and which need more demand (Marketing Push).
- **`snapshot_*.json`**: Machine-readable records for historical tracking.

### 5.4 `results/data/`
**Target Audience:** Developers / API.
- **`gap_summary.json`**: A lightweight JSON response intended for integration with the Rently web platform (e.g., to show a "High Demand" badge on the frontend).

---

## 6. Technical Methodology Deep Dive

### 6.1 The Gap Score Formula
The project uses a smoothed ratio to quantify imbalance:

$$ \text{Gap Score} = \frac{\text{Total Demand} + 1}{\text{Total Supply} + 1} $$

**Why +1?**
This is a smoothing technique (Laplace smoothing). It prevents:
1.  **Division by Zero:** If a new category has 0 products, we don't want the code to crash.
2.  **Exploding Scores:** If a category has 1 product and 100 orders (Score ~50), it is comparable to 10 products and 1000 orders (Score ~90). Without smoothing, 0 supply would be undefined.

### 6.2 Severity Classification
We map the continuous Gap Score to discrete business statuses:

| Score Range | Status | Meaning | Action |
|:-----------|:-------|:--------|:-------|
| < 50 | **Low** | Balanced | Maintain current strategy. |
| 50 - 100 | **Moderate** | Slight Shortage | Monitor closely. |
| 100 - 200 | **High** | Significant Shortage | Increase supply incentives. |
| > 200 | **Critical** | Severe Shortage | Immediate operational intervention. |

---

## 7. Conclusion

The **Rently 2026 Gap Analysis** project is a comprehensive, end-to-end data solution. By moving beyond simple spreadsheets to a code-based architecture, the team has established a repeatable, automated process for identifying market opportunities.

The integration of **Python modules (`src`)** with **Notebook workflows** ensures that the logic is robust while the analysis remains flexible. The multi-format outputs (Excel, HTML, JSON) ensure that the insights are accessible to every stakeholder, from the C-suite to the operations floor. This system provides the data-driven foundation necessary for Rently to optimize its marketplace balance and maximize revenue in 2026.
