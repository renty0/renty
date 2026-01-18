
import os
import sys
import pandas as pd
from pathlib import Path

# Add src to python path to allow imports
current_dir = Path(__file__).parent
src_path = current_dir.parent / 'src'
sys.path.append(str(src_path))

from data.loader import load_excel_sheets
from analysis.supply_demand import (compute_category_supply, compute_category_demand, merge_supply_demand)
from analysis.gap_score import (compute_gap_score, normalize_gap_score, classify_gap_level)
from visualization.dashboards.gap_builder import prepare_gap_summary, export_gap_summary

def run_analysis():
    print("Starting Gap Analysis Pipeline...")
    
    # 1. Load Data
    data_path = current_dir.parent / 'data' / 'processed' / 'Cleaned_data.xlsx'
    print(f"Loading data from: {data_path}")
    
    datasets = load_excel_sheets(str(data_path))
    if not datasets:
        print("Failed to load datasets. Exiting.")
        return

    # Check required sheets
    required_sheets = ['Sales Data', ' Product Lookup']
    for sheet in required_sheets:
        if sheet not in datasets:
             print(f"Warning: Sheet {sheet} not found in {list(datasets.keys())}")

    # Inspect keys to be safe
    # print("Available sheets:", list(datasets.keys()))
    
    # Map to correct sheet names
    sales_data = datasets.get('Sales Data')
    
    # We need to construct the full product view since we likely don't have a single 'Product_Details' sheet
    # based on the available sheets list: [' Product Lookup', 'Product Subcategory', 'Product Category']
    
    # If Sales Data doesn't have CategoryName, we MUST merge.
    if 'CategoryName' not in sales_data.columns:
        print("Merging lookup tables...")
        # Note the leading space in ' Product Lookup' based on the error log
        product_lookup = datasets.get(' Product Lookup')
        subcategories = datasets.get('Product Subcategory')
        categories = datasets.get('Product Category')
        
        if product_lookup is None or subcategories is None or categories is None:
            print("Error: Missing required lookup sheets for merging.")
            print(f"Available: {list(datasets.keys())}")
            return

        # Merge products -> subcats -> cats
        # Verify columns exist before merge (optional but good practice, assuming standard schema for now)
        products_full = product_lookup.merge(subcategories, left_on='ProductSubcategoryKey', right_on='ProductSubcategoryKey', how='left')
        products_full = products_full.merge(categories, left_on='ProductCategoryKey', right_on='ProductCategoryKey', how='left')
        
        # Merge sales -> products_full
        sales_full = sales_data.merge(products_full[['ProductKey', 'CategoryName', 'SubcategoryName']], on='ProductKey', how='left')
    else:
        sales_full = sales_data
        
        # For supply, we need a products listing.
        # Create products_full from lookups
        product_lookup = datasets.get(' Product Lookup')
        subcategories = datasets.get('Product Subcategory')
        categories = datasets.get('Product Category')
        
        if product_lookup is not None and subcategories is not None and categories is not None:
             products_full = product_lookup.merge(subcategories, left_on='ProductSubcategoryKey', right_on='ProductSubcategoryKey', how='left')
             products_full = products_full.merge(categories, left_on='ProductCategoryKey', right_on='ProductCategoryKey', how='left')
        else:
             print("Warning: Could not create products_full, supply analysis might fail.")
             products_full = pd.DataFrame() # Empty fallback

    # 2. Compute Supply & Demand
    print("Computing Supply and Demand...")
    supply = compute_category_supply(sales_full, products_full)
    demand = compute_category_demand(sales_full)
    
    # 3. Merge and Compute Scores
    print("Calculating Gap Scores...")
    merged = merge_supply_demand(supply, demand)
    gap_df = compute_gap_score(merged)
    gap_df = normalize_gap_score(gap_df)
    gap_df = classify_gap_level(gap_df)
    
    # 4. Prepare Summary
    summary = prepare_gap_summary(gap_df)
    
    # 5. Export
    print("Exporting results...")
    csv_path, json_path = export_gap_summary(summary)
    
    print(f"Success! Results saved to:\nJSON: {json_path}\nCSV: {csv_path}")

if __name__ == "__main__":
    try:
        run_analysis()
    except Exception as e:
        print(f"Error during analysis: {e}")
        import traceback
        traceback.print_exc()
