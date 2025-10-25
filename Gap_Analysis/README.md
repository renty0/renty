# Gap Analysis Project - Data Understanding & Exploration

**Analyst:** Hamza
**Version:** 1.0.0

---

## Executive Summary

This project implements a comprehensive data analysis pipeline for gap analysis in business intelligence. The analysis examines eight interconnected datasets totaling 76,266 records to identify market gaps, customer segments, and business opportunities across product portfolios, customer demographics, sales patterns, and territorial performance.

---

## Project Structure

---

## Dataset Overview

| Dataset | Records | Columns | Description |
|---------|---------|---------|-------------|
| Product Lookup | 293 | 12 | Product catalog with pricing, colors, and styles |
| Customer Lookup | 18,148 | 15 | Customer demographics, income, education, occupation |
| Product Subcategory | 37 | 3 | Product subcategory classifications |
| Product Category | 4 | 2 | Main categories: Bikes, Components, Clothing, Accessories |
| Territory Lookup | 10 | 4 | Geographic coverage: 6 countries, 4 continents |
| Returns Data | 1,809 | 4 | Product return transactions with dates and quantities |
| Sales Data | 56,046 | 8 | Order transactions linking customers, products, territories |
| Calendar Lookup | 912 | 9 | Date dimension spanning 3 years (2020-2022) |

**Total Records:** 76,266 across 8 interconnected datasets

---

## Methodology & Analysis Process

### Phase 1: Data Loading & Overview
**Objective:** Load all datasets and generate initial summaries

**Implementation:**
- Used `pandas.ExcelFile` for multi-sheet Excel processing
- Created automated summary generation function
- Generated dataset dimensions, missing value counts, duplicate detection

**Results:**
- All 8 datasets loaded successfully
- Zero duplicate records found across all datasets
- Initial quality assessment completed

### Phase 2: Structure & Relationships
**Objective:** Understand data structure and identify relationships

**Analysis Performed:**
- Data type inspection for all 57 unique columns
- Unique value counting and cardinality analysis
- Primary and foreign key identification
- Database relationship modeling using DBML format

**Key Relationships Identified:**
- Sales Data → Customer Lookup (via CustomerKey)
- Sales Data → Product Lookup (via ProductKey)
- Sales Data → Territory Lookup (via TerritoryKey)
- Product Lookup → Product Subcategory → Product Category (hierarchical)
- Sales/Returns → Calendar Lookup (temporal relationships)

**Output:** Complete entity-relationship diagram visualizing all table connections

### Phase 3: Data Quality Assessment
**Objective:** Identify and quantify data quality issues

**Tools & Techniques:**
- Missing value detection using pandas `isna()`
- Heatmap visualization with seaborn
- Statistical summary generation

**Quality Findings:**

| Issue Type | Dataset | Details |
|------------|---------|---------|
| Missing Values | Product Lookup | ProductStyle: 84 (28.67%), ProductColor: 50 (17.06%) |
| Missing Values | Customer Lookup | Prefix & Gender: 130 each (0.72%) |
| Data Issues | Territory Lookup | Typo: "Europee" instead of "Europe" |
| Redundant Data | Customer Lookup | Domain Name column (single value) |
| Duplicates | All Datasets | Zero duplicate records |
| Completeness | Sales & Returns | 100% complete transactional data |

### Phase 4: Statistical Analysis
**Objective:** Understand distributions and statistical characteristics

**Numerical Analysis:**
- 111 unique product cost points
- 107 distinct price levels
- 16 income brackets for customer segmentation
- 3 standardized order quantity values
- 2 return quantity values (1-2 units)

**Categorical Insights:**

**Product Distribution:**
- Color: Black (88), Red (37), Silver (36), Yellow (36)
- Style: Highly imbalanced - U (174), W (28), M (7)
- Top Models: LL Road Frame (12), Road-650 (12)

**Customer Demographics:**
- Gender: Balanced - Male (50.3%), Female (49.7%)
- Marital Status: Married (54%), Single (46%)
- Education: Bachelors (29%), Partial College (27%)
- Occupation: Professional (30%), Skilled Manual (25%)
- Home Ownership: Owners (67%), Renters (33%)

**Geographic Coverage:**
- 10 territories across United States (5 regions) and international markets
- 6 countries: USA, Canada, France, Germany, Australia, UK
- 4 continents with emphasis on North America

**Temporal Scope:**
- 912 days of data (2020-2022)
- 25,164 unique orders with 56,046 line items
- 1,809 returns across 476 unique dates
- 17,416 unique customers made purchases (96% engagement rate)

---

## Key Findings & Recommendations

### Data Quality Summary
✓ **Strengths:** Zero duplicates, complete transactional data, well-balanced demographics  
⚠ **Issues:** Missing product attributes (28.67% style, 17.06% color), minor typos  
✓ **Relationships:** All foreign keys validated, complete hierarchical structure

### Identified Market Gaps
1. **Product Segmentation Gap:** Missing color/style attributes limit detailed analysis
2. **Geographic Balance:** Uneven territory distribution suggests expansion opportunities
3. **Product Portfolio:** Style distribution heavily skewed (U-style dominant)
4. **Data Anomalies:** 38 duplicate customer names require investigation

### Immediate Actions Required
1. Impute or categorize missing ProductColor/Style values (28.67% and 17.06%)
2. Standardize date columns to datetime format
3. Correct continent field typo ("Europee" → "Europe")
4. Remove redundant Domain Name column
5. Investigate duplicate customer names with unique CustomerKeys

### Strategic Recommendations
**Market Gaps:** Analyze underrepresented customer segments and low-penetration territories  
**Product Portfolio:** Assess color/style coverage gaps and pricing strategy opportunities  
**Customer Segments:** Map demographic coverage to identify underserved income brackets  
**Geographic Expansion:** Evaluate territory performance metrics and international potential

---

## Technical Implementation

**Core Technologies:**
- **pandas 2.x:** Data manipulation, Excel processing, statistical analysis
- **matplotlib 3.x:** Data visualization and plotting
- **seaborn:** Statistical graphics and heatmaps
- **IPython:** Interactive notebook environment

**Module Architecture:**
- `data_loader.py`: Multi-sheet Excel loading with error handling
- `data_quality.py`: Missing value analysis and heatmap generation
- `data_statistics.py`: Numerical and categorical distribution analysis
- `data_relationships.py`: Structure exploration and relationship inference
- `data_db_model.py`: DBML schema generation and ER diagram creation
- `visualization.py`: Reusable plotting functions for consistent graphics
- `config.py`: Centralized path management and directory initialization

---

## Next Steps

**Phase 1: Data Preprocessing**
- Handle missing values systematically using imputation or categorization
- Convert date columns to datetime format for temporal analysis
- Standardize data types across all datasets
- Create derived metrics and aggregate features

**Phase 2: Gap Analysis Modeling**
- Develop gap identification algorithms for market opportunities
- Create customer segment scoring models
- Build predictive models for geographic expansion
- Generate market opportunity scores

**Phase 3: Visualization & Reporting**
- Design executive dashboards for stakeholder communication
- Generate comprehensive gap analysis reports
- Develop interactive visualizations for exploration
- Present actionable recommendations with supporting evidence

---

## Conclusion

This data understanding phase successfully analyzed 76,266 records across eight interconnected datasets. The analysis revealed high-quality transactional data with minor attribute gaps that can be systematically addressed. The comprehensive understanding of data structure (57 columns), validated relationships (6 foreign key connections), and statistical characteristics provides a solid foundation for advanced gap analysis modeling.

The datasets support multiple dimensions of analysis including customer segmentation (5 demographic factors), product portfolio optimization (293 products across 4 categories), geographic expansion (10 territories), and market opportunity identification. With 96% customer engagement and complete temporal coverage, the data enables sophisticated modeling for actionable business intelligence.

---

**Document Version:** 1.0 | **Author:** Hamza | **Date:** 2025

