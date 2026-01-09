# **Supply–Demand Gap Analysis for Rental Platform**

### *Comprehensive Technical Documentation*

### *Vodafone International Foundation – Faculty of Engineering*

---

## **Prepared By**

* **Hamza Omran**
* **Ahmad Khalifa**
* **Moaz Mostafa**

---

## **Abstract**

This document presents a comprehensive Supply–Demand Gap Analysis conducted for a rental business platform. The project identifies supply shortages across product categories by computing gap scores derived from the ratio of customer demand to available product listings. Using a data-driven methodology, the analysis integrates eight datasets covering products, sales, returns, customer demographics, and geographic territories across three years (2020–2022).

The multi-phase pipeline includes data exploration, cleaning, supply–demand computation, gap score calculation, visualization, business insight generation, and weekly monitoring with action planning. The project outputs interactive dashboards, Excel reports, PNG charts, structured JSON files, and an API-ready analytics layer.

The findings highlight severe shortages in multiple subcategories, with gap scores exceeding 200, signaling critical supply deficits. The implemented monitoring framework enables ongoing tracking and provides prioritized operational and strategic recommendations for decision-makers.

---

# **Table of Contents**

1. Introduction
   1.1 Project Overview
   1.2 Problem Statement
   1.3 Objectives
   1.4 Scope and Limitations

2. Literature Review
   2.1 Supply–Demand Analysis
   2.2 Gap Score Methodology
   2.3 Data-Driven Decision Making

3. Methodology
   3.1 Data Pipeline Architecture
   3.2 Data Sources and Structure
   3.3 Gap Score Formula
   3.4 Classification Criteria

4. Implementation
   4.1 Phase 1: Data Preparation
   4.2 Phase 2: Supply–Demand Computation
   4.3 Phase 3: Gap Score Calculation
   4.4 Phase 4: Visualization and Insights
   4.5 Phase 5: Monitoring and Action Planning

5. Technical Architecture
   5.1 Python Modules
   5.2 Notebook Workflow
   5.3 Output Files and Deliverables

6. Results and Analysis
   6.1 Category-Level Findings
   6.2 Subcategory-Level Findings
   6.3 Territory-Level Findings
   6.4 Gap Severity Distribution

7. Visualizations
   7.1 Supply vs Demand
   7.2 Gap Severity
   7.3 Heatmaps
   7.4 Category Rankings
   7.5 Gap Distribution

8. Business Insights
   8.1 Critical Gaps
   8.2 Balanced Categories
   8.3 Strategic Recommendations

9. Monitoring Framework
   9.1 Weekly Snapshots
   9.2 KPI Tracking
   9.3 Alert System

10. Action Plans
    10.1 Operational Actions
    10.2 Strategic Actions
    10.3 Platform Optimization
    10.4 User Engagement

11. API Integration
    11.1 Endpoint Recommendations
    11.2 Data Export Formats
    11.3 Usage Examples

12. Conclusion

13. Future Work

14. References

15. Appendices

---

# **1. Introduction**

## **1.1 Project Overview**

This project addresses the challenge of identifying supply–demand imbalance within a rental marketplace by computing gap scores that quantify shortages at category, subcategory, and territorial levels. The analysis uses transactional data comprising:

* **56,046 sales transactions**
* **293 unique products**
* **18,148 customers**
* **1,809 returns**
* **37 subcategories**
* **10 territories and 6 countries**

The pipeline transforms raw multi-source data into actionable insights using a modular architecture of notebooks and Python modules.

---

## **1.2 Problem Statement**

Many rental platforms struggle with:

* Lack of quantitative measurement of supply shortages
* Missing visibility into which subcategories experience high unmet demand
* Absence of automated monitoring mechanisms
* Difficulty in allocating inventory budgets
* Limited understanding of territory-level demand patterns

This project delivers a full analytical framework to solve these challenges.

---

## **1.3 Objectives**

* Develop a gap score methodology to quantify supply deficits
* Implement an automated end-to-end data pipeline
* Compute supply–demand metrics across all categories and territories
* Generate insights through visualization and interpretation
* Build a weekly monitoring system
* Produce prioritized action plans
* Deliver API-ready datasets for integration

---

## **1.4 Scope and Limitations**

### **Scope**

* Category, subcategory, and territory-level analysis
* Data cleaning, gap computation, visualization, insights
* Action planning and monitoring

### **Limitations**

* Historical (not predictive) analysis
* Linear assumption in demand/supply relationships
* Does not incorporate pricing or time-of-day patterns
* Excludes external market influences

---

# **2. Literature Review**

## **2.1 Supply–Demand Analysis**

Supply–demand modeling is fundamental in resource allocation, revealing where inventory shortages constrain customer satisfaction and revenue potential.

## **2.2 Gap Score Methodology**

Ratio-based methods quantify shortages effectively, enabling clear action prioritization.

## **2.3 Data-Driven Decision Making**

Modern commerce relies on analytical pipelines integrating data cleaning, computation, visualization, and automation — which this project implements.

---

# **3. Methodology**

## **3.1 Data Pipeline Architecture**

The pipeline consists of **five phases**, each implemented in Jupyter notebooks with modular Python code:

```
Phase 1 – Data Preparation
Phase 2 – Supply–Demand Computation
Phase 3 – Gap Score Calculation
Phase 4 – Visualization and Insights
Phase 5 – Monitoring and Action Planning
```

## **3.2 Data Sources**

Eight sheets from “Project Data.xlsx,” including:

* Products
* Product Categories
* Sales
* Customers
* Returns
* Territories

## **3.3 Gap Score Formula**

```
Gap Score = (Total Demand + 1) / (Total Supply + 1)
```

## **3.4 Classification Criteria**

| Gap Level | Range   | Meaning               |
| --------- | ------- | --------------------- |
| Low       | < 50    | Balanced              |
| Moderate  | 50–100  | Mild shortages        |
| High      | 100–200 | Significant shortages |
| Critical  | > 200   | Severe shortages      |

---

# **4. Implementation**

## **4.1 Phase 1 – Data Preparation**

Handled in notebooks:

* DataUnderstandingAndExploration.ipynb
* DataCleaningAndMerging.ipynb

Tasks:

* Missing value handling
* Customer gender inference
* Prefix generation
* Date type consistency
* Export cleaned dataset

### **Color Cleaning Summary**

| Color  | Count (Before) | Count (After) |
| ------ | -------------- | ------------- |
| Black  | 88             | 88            |
| Mixed  | 0 (50 NaN)     | 50            |
| Red    | 37             | 37            |
| Silver | 36             | 36            |
| Yellow | 36             | 36            |

### **Style Cleaning Summary**

| Style      | Count (Before) | Count (After) |
| ---------- | -------------- | ------------- |
| U (Unisex) | 174            | 258           |
| W          | 28             | 28            |
| M          | 7              | 7             |
| NaN        | 84             | 0             |

### **Prefix Generation Summary**

| Prefix  | Before | After |
| ------- | ------ | ----- |
| Mr.     | 9,126  | 9,206 |
| Mrs.    | 6,422  | 6,426 |
| Ms.     | 2,470  | 2,516 |
| Missing | 130    | 0     |

---

## **4.2 Phase 2 – Supply–Demand Computation**

Calculates:

* Category supply (unique products)
* Category demand (quantity sold)
* Returns adjustment
* Monthly trends

**Output**:
`Category_Supply_Demand_Analysis.xlsx`

---

## **4.3 Phase 3 – Gap Score Calculation**

Notebooks:

* MOAZ_Define_Metrics_GapScore.ipynb
* GapScoreImplementation.ipynb

Outputs:

* Category-level gap scores
* Subcategory-level gap scores
* Territory-level gap scores
* Cross-analysis (subcategory × territory)

Stored in:

`comprehensive_gap_analysis.xlsx`

---

## **4.4 Phase 4 – Visualization and Insights**

Generates:

* Supply vs Demand chart
* Gap severity chart
* Heatmap of normalized metrics
* Category/subcategory rankings
* Gap distribution pie chart

Placeholder images included below.

---

## **4.5 Phase 5 – Monitoring and Action Planning**

Creates:

* Weekly snapshots
* KPI calculations
* Alerts for categories with rising gaps
* Action plans (operational, strategic, technical)

Outputs stored in:

`results/monitoring_reports/`
`results/monitoring_dashboards/`

---

# **5. Technical Architecture**

## **5.1 Python Modules**

The project consists of **21 modules**, including:

* Data processing (loader, cleaner, relationships)
* Supply–demand computation
* Gap score engine
* Visualization modules (Plotly + Matplotlib)
* Monitoring engine
* Action planner
* Dashboard and chart builders
* Data exporters

---

## **5.2 Notebook Workflow**

Executed in exact order:

1. Understanding
2. Cleaning
3. Supply–Demand
4. Metrics definition
5. Gap score implementation
6. Visualization
7. Insights
8. Monitoring and action planning

---

## **5.3 Output Files**

* Excel reports
* PNG charts
* Interactive HTML dashboards
* JSON and CSV exports
* Insights reports

---

# **6. Results and Analysis**

## **6.1 Category-Level Findings**

Certain categories show stable supply–demand balance, while others indicate severe shortages requiring immediate product acquisition.

## **6.2 Subcategory-Level Findings**

Multiple subcategories exhibit **critical gap scores > 200**, signaling extremely high unmet demand.

## **6.3 Territory-Level Findings**

Across 10 territories, regional shortages were identified, informing localized supply expansion strategies.

## **6.4 Gap Severity Distribution**

The analysis shows a high proportion of High and Critical categories.

---

# **7. Visualizations**

## **7.1 Supply vs Demand**

![Supply vs Demand](charts/01_supply_vs_demand.png)

## **7.2 Gap Severity Chart**

![Gap Severity](charts/02_gap_severity.png)

## **7.3 Heatmap**

![Gap Heatmap](charts/03_gap_heatmap.png)

## **7.4 Category Rankings**

![Category Rankings](charts/04_category_rankings.png)

## **7.5 Gap Distribution**

![Gap Distribution](charts/05_gap_distribution.png)

---

# **8. Business Insights**

## **8.1 Critical Gaps**

* Several subcategories exceed gap scores of **200–350**.
* Immediate action required for these areas.

## **8.2 Balanced Categories**

* A minority of categories show balanced supply-demand conditions.

## **8.3 Recommendations**

* Supplier recruitment
* Inventory diversification
* Regional expansion
* Return reduction policies
* Demand-driven sourcing

---

# **9. Monitoring Framework**

## **9.1 Weekly Snapshots**

Automatically stored as JSON and CSV.

## **9.2 KPI Tracking**

KPIs include:

* Average gap score
* Supply deficit indicators
* Territory alerts
* Change week-over-week

## **9.3 Alert System**

Flags categories whose gap scores increase beyond thresholds.

---

# **10. Action Plans**

## **10.1 Operational Actions**

* Immediate inventory expansion
* Supplier renegotiation

## **10.2 Strategic Actions**

* Category-level sourcing strategy
* Market expansion

## **10.3 Platform Optimization**

* Improve product discovery
* Enhance supplier dashboards

## **10.4 User Engagement**

* Targeted customer outreach
* Recommendation engine integration

---

# **11. API Integration**

## **11.1 Recommended Endpoints**

Sample:

```
GET /api/gaps/categories
GET /api/gaps/subcategories
GET /api/monitoring/kpis
GET /api/actions/current-week
```

## **11.2 Export Formats**

* Excel
* CSV
* JSON
* HTML visualizations

## **11.3 Usage Example**

```python
gaps = compute_gap_score(df)
actions = planner.generate_category_action_plan(gaps)
```

---

# **12. Conclusion**

This project delivers a complete analytical framework for identifying and addressing supply shortages within a rental platform. Through a robust pipeline, modular codebase, interactive visualizations, and monitoring tools, stakeholders gain actionable insights to guide operational and strategic decisions.

---

# **13. Future Work**

* Predictive modeling
* Dynamic pricing
* Real-time alert systems
* ML-based gap prediction
* Automated supplier notifications

---

# **14. References**

(List included exactly as provided)

---

# **15. Appendices**

* Data Dictionary
* Module API documentation
* Full gap score tables
* All action plans
* Installation guide


