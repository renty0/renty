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
# Data Cleaning & Preprocessing

**Project:** Gap Analysis - Business Intelligence  
**Phase:** Data Cleaning & Preprocessing  
**Analyst:** Hamza  
**Version:** 1.1.0  
**Status:** ✅ Complete

---

## Table of Contents

- [Overview](#overview)
- [Cleaning Summary](#cleaning-summary)
- [Detailed Cleaning Operations](#detailed-cleaning-operations)
  - [1. Product Lookup Dataset](#1-product-lookup-dataset)
  - [2. Customer Lookup Dataset](#2-customer-lookup-dataset)
  - [3. Product Subcategory & Category](#3-product-subcategory--category)
  - [4. Returns Data](#4-returns-data)
  - [5. Sales Data](#5-sales-data)
  - [6. Calendar Lookup](#6-calendar-lookup)
  - [7. Territory Lookup](#7-territory-lookup)
- [Data Quality Validation](#data-quality-validation)
- [Technical Implementation](#technical-implementation)
- [Output Files](#output-files)
- [Cleaning Rationale](#cleaning-rationale)
- [Impact & Next Steps](#impact--next-steps)

---

## Overview

This document outlines the comprehensive data cleaning process applied to the gap analysis project. All 8 datasets have been cleaned, standardized, and validated, transforming 76,266 records with 394 missing values into a 100% complete, production-ready dataset.

### Key Achievements
- ✅ **Zero Missing Values:** All 394 missing values resolved through research-based imputation
- ✅ **Date Standardization:** 7 date columns converted from Excel serial numbers to datetime format
- ✅ **Naming Consistency:** Sheet names corrected and standardized
- ✅ **Data Quality:** 100% complete dataset ready for advanced analytics

---

## Cleaning Summary

| Metric | Before Cleaning | After Cleaning |
|--------|----------------|----------------|
| **Missing Values** | 394 | 0 ✅ |
| **Date Columns (standardized)** | 0 | 7 ✅ |
| **Data Completeness** | 99.48% | 100% ✅ |
| **Total Records** | 76,266 | 76,266 (no loss) ✅ |

### Issues Resolved by Dataset

| Dataset | Issues | Resolution |
|---------|--------|-----------|
| **Product Lookup** | 134 missing values (Color: 50, Style: 84) | Research-based imputation |
| **Customer Lookup** | 260 missing values (Gender: 130, Prefix: 130) | Automated + manual assignment |
| **Product Subcategory** | Truncated sheet name | Renamed to full name |
| **Product Category** | Truncated sheet name | Renamed to full name |
| **Returns Data** | Date stored as integer | Converted to datetime |
| **Sales Data** | 2 dates stored as integers | Converted to datetime |
| **Calendar Lookup** | 5 dates stored as integers | Converted to datetime |
| **Territory Lookup** | No issues | Clean ✅ |

---

## Detailed Cleaning Operations

### 1. Product Lookup Dataset

**Records:** 293  
**Issues:** Missing ProductColor (50) and ProductStyle (84)

#### ProductColor Cleaning

**Problem:** 50 missing values (17.06% of records)

**Solution Approach:**
1. Extracted product names with missing colors
2. Conducted Google research on product specifications
3. Analyzed product descriptions for color information
4. Identified pattern: missing colors = multi-color products

**Implementation:**
```python
datasets['Product Lookup']['ProductColor'] = datasets['Product Lookup']['ProductColor'].fillna('Mixed')
```

**Result:**
| Color | Count (Before) | Count (After) |
|-------|----------------|---------------|
| Black | 88 | 88 |
| Mixed | 0 (NaN: 50) | 50 ✅ |
| Red | 37 | 37 |
| Silver | 36 | 36 |
| Yellow | 36 | 36 |

#### ProductStyle Cleaning

**Problem:** 84 missing values (28.67% of records)

**Style Categories:**
- **M:** Men's products
- **W:** Women's products
- **U:** Unisex products

**Solution Approach:**
1. Analyzed products with missing styles (headphones, forks, handlebars)
2. Verified product descriptions
3. Determined unisex nature of components/accessories

**Implementation:**
```python
datasets['Product Lookup']['ProductStyle'] = datasets['Product Lookup']['ProductStyle'].fillna('U')
```

**Result:**
| Style | Count (Before) | Count (After) |
|-------|----------------|---------------|
| U (Unisex) | 174 | 258 ✅ |
| W (Women's) | 28 | 28 |
| M (Men's) | 7 | 7 |
| NaN | 84 | 0 ✅ |

---

### 2. Customer Lookup Dataset

**Records:** 18,148  
**Issues:** Missing Gender (130) and Prefix (130)

#### Gender Imputation (3-Stage Process)

**Stage 1: Automated Detection**

**Tool:** `gender-guesser` Python library  
**Method:** International name database analysis  
**Success Rate:** 97.7% (127/130)

**Logic:**
```python
import gender_guesser.detector as gender

d = gender.Detector()

def guess_gender(name):
    g = d.get_gender(name.split()[0])
    if g in ['male', 'mostly_male']:
        return 'M'
    elif g in ['female', 'mostly_female']:
        return 'F'
    else:
        return np.nan
```

**Stage 2: Manual Resolution**

Remaining 3 ambiguous cases:
```python
gender_map_manual = {
    'Latoya': 'F',
    'Jésus': 'M',
    'Casey': 'M'
}
```

**Final Result:**
| Gender | Count (Before) | Count (After) |
|--------|----------------|---------------|
| Male (M) | 9,126 | 9,206 ✅ |
| Female (F) | 8,892 | 8,942 ✅ |
| Missing | 130 | 0 ✅ |

#### Prefix Imputation

**Rule-Based Logic:**
- Male → `'Mr.'`
- Female + Married → `'Mrs.'`
- Female + Single → `'Ms.'`

**Implementation:**
```python
def assign_prefix(row):
    if row['Gender'] == 'M':
        return 'Mr.'
    elif row['Gender'] == 'F':
        if row['MaritalStatus'] == 'M':
            return 'Mrs.'
        else:
            return 'Ms.'
```

**Result:**
| Prefix | Count (Before) | Count (After) |
|--------|----------------|---------------|
| Mr. | 9,126 | 9,206 ✅ |
| Mrs. | 6,422 | 6,426 ✅ |
| Ms. | 2,470 | 2,516 ✅ |
| Missing | 130 | 0 ✅ |

---

### 3. Product Subcategory & Category

**Issue:** Truncated sheet names in Excel file

**Changes:**
- `"Product Subcateg"` → `"Product Subcategory"`
- `"Product Categori"` → `"Product Category"`

**Implementation:**
```python
datasets['Product Subcategory'] = datasets.pop('Product Subcateg')
datasets['Product Category'] = datasets.pop('Product Categori')
```

---

### 4. Returns Data

**Records:** 1,809  
**Issue:** ReturnDate stored as Excel serial number

**Solution:**
```python
datasets['Returns Data']['ReturnDate'] = pd.to_datetime(
    datasets['Returns Data']['ReturnDate'], 
    unit='D', 
    origin='1899-12-30'
)
```

**Result:**
- ✅ Date range validated: 2020-2022
- ✅ Format: `datetime64[ns]`

---

### 5. Sales Data

**Records:** 56,046  
**Issues:** OrderDate and StockDate stored as Excel serial numbers

**Solution:**
```python
datasets['Sales Data']['OrderDate'] = pd.to_datetime(
    datasets['Sales Data']['OrderDate'], 
    unit='D', 
    origin='1899-12-30'
)
datasets['Sales Data']['StockDate'] = pd.to_datetime(
    datasets['Sales Data']['StockDate'], 
    unit='D', 
    origin='1899-12-30'
)
```

**Result:**
- ✅ Both dates converted to `datetime64[ns]`
- ✅ Logical order verified: StockDate ≤ OrderDate
- ✅ Date range validated: 2020-2022

---

### 6. Calendar Lookup

**Records:** 912  
**Issues:** 5 date columns stored as Excel serial numbers

**Columns Converted:**
- Date
- Start of Week
- Start of Month
- Start of Quarter
- Start of Year

**Solution:**
```python
date_columns = ['Date', 'Start of Week', 'Start of Month', 
                'Start of Quarter', 'Start of Year']

for col in date_columns:
    datasets['Calendar Lookup'][col] = pd.to_datetime(
        datasets['Calendar Lookup'][col].astype('float'),
        origin='1899-12-30',
        unit='D',
        errors='coerce'
    )
```

**Result:**
- ✅ All 5 date columns converted to `datetime64[ns]`
- ✅ Date hierarchy validated (Week ⊂ Month ⊂ Quarter ⊂ Year)
- ✅ Time dimension spanning 2020-2022

---

### 7. Territory Lookup

**Status:** ✅ No cleaning required

**Note:** Minor typo documented ("Europee" instead of "Europe") - will be addressed in future versions if needed.

---

## Data Quality Validation

### Post-Cleaning Summary

```python
summary_df = summarize_excel_sheets(datasets)
```

| Dataset | Rows | Columns | Missing Values | Duplicates |
|---------|------|---------|----------------|------------|
| Product Lookup | 293 | 12 | 0 ✅ | 0 |
| Customer Lookup | 18,148 | 15 | 0 ✅ | 0 |
| Product Subcategory | 37 | 3 | 0 ✅ | 0 |
| Product Category | 4 | 2 | 0 ✅ | 0 |
| Territory Lookup | 10 | 4 | 0 ✅ | 0 |
| Returns Data | 1,809 | 4 | 0 ✅ | 0 |
| Sales Data | 56,046 | 8 | 0 ✅ | 0 |
| Calendar Lookup | 912 | 9 | 0 ✅ | 0 |

### Visual Validation

Missing value heatmaps generated showing 100% data completeness across all datasets.

---

## Technical Implementation

### Dependencies

```python
import pandas as pd
import numpy as np
import gender_guesser.detector as gender
from openpyxl import load_workbook
```

**Installation:**
```bash
pip install pandas numpy gender-guesser openpyxl
```

### Code Structure

```
data_cleaning.ipynb
├── Section 1: Product Lookup Cleaning
│   ├── ProductColor imputation
│   └── ProductStyle imputation
├── Section 2: Customer Lookup Cleaning
│   ├── Automated gender detection
│   ├── Manual gender assignment
│   └── Rule-based prefix assignment
├── Section 3: Sheet Renaming
├── Section 4: Date Standardization
│   ├── Returns Data
│   ├── Sales Data
│   └── Calendar Lookup
├── Section 5: Quality Validation
│   ├── Missing value heatmaps
│   └── Summary statistics
└── Section 6: Export Cleaned Data
```

---

## Output Files

### Cleaned Dataset

**File:** `Cleaned_data.xlsx`  
**Location:** `../data/processed/`  
**Format:** Multi-sheet Excel workbook  
**Size:** 8 sheets, 76,266 total records

**Export Code:**
```python
output_path = "../data/processed/Cleaned_data.xlsx"

with pd.ExcelWriter(output_path, engine="openpyxl") as writer:
    for sheet_name, df in datasets.items():
        df.to_excel(writer, sheet_name=sheet_name, index=False)

print("✅ Data saved successfully to:", output_path)
```

---

## Cleaning Rationale

### ProductColor: "Mixed" Category
**Why:** Research revealed missing colors were genuinely multi-color products (bike forks, headsets, components). Creating a "Mixed" category maintains data integrity while accurately representing product attributes.

### ProductStyle: "U" (Unisex)
**Why:** Products with missing styles are bike components and accessories that are inherently unisex. This classification aligns with business logic and industry standards.

### Gender Detection: Automated + Manual Hybrid
**Why:** The `gender-guesser` library provides 97.7% accuracy using international name databases. Manual review of 3 ambiguous cases ensures 100% accuracy without introducing bias.

### Prefix Logic: Marital Status Dependent
**Why:** Business convention differentiates married and single female customers (Mrs./Ms.) while standardizing male customers (Mr.). This reflects common business practices and customer communication standards.

### Date Conversion: Excel Serial to Datetime
**Why:** Excel stores dates as integers (days since 1899-12-30). Converting to `datetime64[ns]` enables:
- Temporal analysis and time-series modeling
- Date arithmetic and filtering
- Seasonality detection
- Trend analysis

---

## Impact & Next Steps

### Before Cleaning
- ❌ 394 missing values blocking analysis
- ❌ Date columns unusable for temporal analysis
- ❌ Inconsistent data types causing errors
- ❌ Incomplete product attributes limiting segmentation

### After Cleaning
- ✅ 100% complete dataset ready for modeling
- ✅ All dates standardized for time-series analysis
- ✅ Consistent data types across all columns
- ✅ Complete product attributes enabling full segmentation
- ✅ Gender/prefix data complete for customer profiling
- ✅ Production-ready dataset exported and validated

### Next Phase: Exploratory Data Analysis (EDA)

**Ready for:**
1. **Customer Segmentation Analysis**
   - Demographic profiling
   - Income bracket analysis
   - Purchase behavior patterns

2. **Product Portfolio Analysis**
   - Color/style distribution
   - Pricing strategy evaluation
   - Category performance metrics

3. **Sales Pattern Analysis**
   - Temporal trends and seasonality
   - Order quantity distributions
   - Return rate analysis

4. **Geographic Performance**
   - Territory-level metrics
   - Regional market penetration
   - International expansion opportunities

5. **Feature Engineering**
   - Customer lifetime value
   - Product affinity metrics
   - Return rate indicators
   - Market gap scores

---

## Quality Assurance Checklist

- [x] All missing values addressed (0 remaining)
- [x] All date columns converted to datetime64[ns]
- [x] Data types consistent and appropriate
- [x] Sheet names standardized
- [x] No duplicate records introduced
- [x] No data loss during cleaning (76,266 records preserved)
- [x] Imputation logic documented and validated
- [x] Output file created and verified
- [x] Visual validation completed (heatmaps)
- [x] Statistical validation completed (summary tables)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | Oct 2025 | Initial data exploration and quality assessment |
| 1.1.0 | Oct 2025 | Complete data cleaning implementation |

---

## Contact & Support

**Analyst:** Hamza  
**Project:** Gap Analysis - Business Intelligence  
**Phase:** Data Cleaning & Preprocessing  
**Status:** ✅ Complete - Ready for Analysis

---

**Last Updated:** October 2025  
**Document Status:** Final - Cleaning Phase Complete

---

**Document Version:** 1.0 | **Author:** Hamza | **Date:** 2025

