import os
import sys
import argparse
import pandas as pd
from pathlib import Path

# Add src to python path to allow imports
current_dir = Path(__file__).parent
src_path = current_dir.parent / 'src'
sys.path.append(str(src_path))

from data.loader import load_excel_sheets, load_json_data
from analysis.supply_demand import (compute_category_supply, compute_category_demand, merge_supply_demand)
from analysis.gap_score import (compute_gap_score, normalize_gap_score, classify_gap_level)
from visualization.dashboards.gap_builder import prepare_gap_summary, export_gap_summary

def run_analysis(live=False):
    print(f"Starting Gap Analysis Pipeline (Mode: {'Live' if live else 'Static'})...")
    
    if live:
        # 1. Load Live JSON Data (Already summarized by API)
        data_path = current_dir.parent / 'data' / 'live_data.json'
        print(f"Loading live data from: {data_path}")
        
        gap_df = load_json_data(str(data_path))
        if gap_df.empty:
            print("Failed to load live data. Exiting.")
            return

        # Rename columns to match analysis expectations
        # The JSON has {category, supply, demand}
        gap_df.columns = ['CategoryName', 'UniqueProducts', 'TotalQuantitySold']
    else:
        # 1. Load Static Excel Data
        data_path = current_dir.parent / 'data' / 'processed' / 'Cleaned_data.xlsx'
        print(f"Loading static data from: {data_path}")
        
        datasets = load_excel_sheets(str(data_path))
        if not datasets:
            print("Failed to load datasets. Exiting.")
            return

        sales_data = datasets.get('Sales Data')
        
        # Merge lookup tables if needed
        product_lookup = datasets.get(' Product Lookup')
        subcategories = datasets.get('Product Subcategory')
        categories = datasets.get('Product Category')
        
        if product_lookup is not None and subcategories is not None and categories is not None:
             products_full = product_lookup.merge(subcategories, left_on='ProductSubcategoryKey', right_on='ProductSubcategoryKey', how='left')
             products_full = products_full.merge(categories, left_on='ProductCategoryKey', right_on='ProductCategoryKey', how='left')
        else:
             print("Warning: Missing required lookup sheets.")
             return

        # Merge sales -> products_full
        sales_full = sales_data.merge(products_full[['ProductKey', 'CategoryName']], on='ProductKey', how='left')
        
        # 2. Compute Supply & Demand
        print("Computing Supply and Demand...")
        supply = compute_category_supply(sales_full, products_full)
        demand = compute_category_demand(sales_full)
        
        # 3. Merge
        gap_df = merge_supply_demand(supply, demand)

    # 4. Compute Scores & Levels
    print("Calculating Gap Scores...")
    gap_df = compute_gap_score(gap_df)
    gap_df = normalize_gap_score(gap_df)
    gap_df = classify_gap_level(gap_df)
    
    # 5. Prepare Summary
    summary = prepare_gap_summary(gap_df)
    
    # 6. Export
    print("Exporting results...")
    csv_path, json_path = export_gap_summary(summary)
    
    print(f"Success! Results saved to:\nJSON: {json_path}\nCSV: {csv_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Gap Analysis Pipeline")
    parser.add_argument("--live", action="store_true", help="Run analysis on live exported data")
    args = parser.parse_args()
    
    try:
        run_analysis(live=args.live)
    except Exception as e:
        print(f"Error during analysis: {e}")
        import traceback
        traceback.print_exc()
